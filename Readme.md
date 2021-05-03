# NixOS-based Django deployment
!! WARNING !! This project has not been updated for a while. You can still use this as a template, but make sure to update the nixpkgs version in `nixpkgs-src.nix`

This Project aims to provide a production grade NixOS configuration for Django projects. By taking your source code and some parameters as input it will return a nixos configuration which serves your Django project.

An exemplary django project with some example NixOS/NixOps configs can be found under `./examples`

## What you will get
 - A PostgreSQL DB with access configured for django
 - A systemd service which serves the project via gunicorn
 - A defined way of passing secrets to Django without leaking them into /nix/store
 - Your static files as a separated build artifact (by default served via whitenoise)
 - Ability to configure some common options like (allowed-hosts, port, processes, threads) through your nix config.
 - Having your `manage.py` globally callable via `manage-projectname` (only via root/sudo)


## Parameters
```nix
{ # MANDATORY
  name,  # create a name for the project
  keys-file,  # path to a file containing secrets
  src,  # derivation of django source code

  # OPTIONAL
  settings, # django settings module like `myproject.settings`
  pkgs ? import ./nixpkgs-src.nix { config = {}; },  # nixpkgs
  python ? import ./python.nix { inherit pkgs; },  # python + modules
  manage-py ? "${src}/manage.py",  # path to manage.py inside src
  static-files ? (import ./static-files.nix { # derivation of static files
    inherit pkgs python src settings name manage-py;
  }),
  wsgi ? "${name}.wsgi",  # django wsgi module like `myproject.wsgi`
  processes ? 5,  # number of proccesses for gunicorn server
  threads ? 5,  # number of threads for gunicorn server
  db-name ? name,  # database name
  user ? "django",  # system user for django
  port ? 80,  # port to bind the http server
  allowed-hosts ? "*",  # string of comma separated hosts
  ...
}:
```



## Prerequisites
Django settings must be configured to:
 - load `SECRET_KEY` and `STATIC_ROOT` from the environment:
    ```python
    SECRET_KEY=environ.get('SECRET_KEY')
    STATIC_ROOT=environ.get('STATIC_ROOT')
    ```
 - load `ALLOWED_HOSTS` from a comma separated list environment variable:
    ```python
    ALLOWED_HOSTS = list(environ.get('ALLOWED_HOSTS', default='').split(','))
    ```
 - use exactly this `DATABASES` configuration:
    ```python
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': environ.get('DB_NAME'),
            'HOST': '',
        }
    }
    ```

To serve static files out of the box, include the whitenoise middleware:
```python
MIDDLEWARE += [ 'whitenoise.middleware.WhiteNoiseMiddleware' ]
STATICFILES_STORAGE = 'whitenoise.storage.CompressedStaticFilesStorage'
```

(See `./examples/djangoproject/djangoproject/settings_nix.py` for full example)


## Secrets / Keys
To pass secrets to django securely:
1. Create a file containing your secrets as environment variables like this:
    ```
    export SECRET_KEY="foo"
    export ANOTHER_SECRET_FOR_DJANGO="bar"
    ```
2. Pass the path of the file via parameter `keys-file`  
    This file will not be managed by nix.
    If you are deploying to a remote host, make sure this file is available. An example on how to do this with NixOps can be found under `./examples/nixops`

A systemd service running as root will later pick up that file and copy it to a destination under `/run/` where only the django system user can read it. Make sure by yourself to protect the source file you uploaded to the remote host with proper permissions or use the provided NixOps example.

## Examples
See `Readme.md` inside `./examples`
