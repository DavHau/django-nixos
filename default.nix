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
  allowed-hosts ? "*",  # comma separated lists of allowed hosts
  ...
}:
with pkgs;
let
  manage-script = ''
    #!/usr/bin/env sh
    sudo -u ${user} sh -c "source /run/${user}/django-keys && DJANGO_SETTINGS_MODULE=${settings} ${python}/bin/python ${manage-py} $@"
  '';
  manage = 
    runCommand 
      "manage-${name}"
      { propagatedBuildInputs = [ src python ]; }
      ''mkdir -p $out/bin
        echo -e '${manage-script}' > $out/bin/manage-${name}
        chmod +x $out/bin/manage-${name}
      '';
in
{
  # manage.py of the project can be called via manage-`projectname`
  environment.systemPackages = [ manage ];

  # create django user
  users.users.${user} = {};

  # The user of django.service might not have permission to access the keys-file.
  # Therefore we copy the keys-file to a place where django has access
  systemd.services.django-keys = {
    description = "Ensure keys are accessible for django";
    wantedBy = [ "django.service" ];
    requiredBy = [ "django.service" ];
    before = [ "django.service" ];
    serviceConfig = { Type = "oneshot"; };
    script = ''
      mkdir -p /run/${user}
      cp ${keys-file} /run/${user}/django-keys
      chmod 400 /run/${user}/django-keys
      chown -R ${user} /run/${user}
    '';
  };

  # We name the service like the specified user.
  # This allows us to have multiple django projects running in parallel
  systemd.services.${user} = {
    description = "${name} django service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      STATIC_ROOT = static-files;
      DJANGO_SETTINGS_MODULE = settings;
      ALLOWED_HOSTS = allowed-hosts;
      DB_NAME = db-name;
    };
    path = [ python src ];
    serviceConfig = {
      LimitNOFILE = "99999";
      LimitNPROC = "99999";
      User = user;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";  # to be able to bind to low number ports
    };
    script = ''
      source /run/${user}/django-keys
      ${python}/bin/python ${manage-py} migrate
      ${python}/bin/gunicorn ${wsgi} \
          --pythonpath ${src} \
          -b 0.0.0.0:${toString port} \
          --workers=${toString processes} \
          --threads=${toString threads}
    '';
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ db-name ];
    ensureUsers = [{
      name = "${user}";
      ensurePermissions = {
        "DATABASE ${db-name}" = "ALL PRIVILEGES";
      };
    }];
    package = pkgs.postgresql_11;
  };
}