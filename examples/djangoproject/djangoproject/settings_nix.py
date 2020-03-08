from .settings import *
from os import environ

DEBUG = False

# We load the secret key from the environment to not have it in /nix/store.
SECRET_KEY=environ.get('SECRET_KEY')

# The static root will be a path under /nix/store/ which we don't know yet.
STATIC_ROOT=environ.get('STATIC_ROOT')

# Allowed hosts are provided via nix config
ALLOWED_HOSTS = list(environ.get('ALLOWED_HOSTS', default='').split(','))

### Postgres Database Connection
# We use a local (non TCP) DB connection by setting HOST to an empty string
# In this mode the user gets authenticated via the OS.
# Only processes of a specific system user will be able to access the DB
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': environ.get('DB_NAME'),
        'HOST': ''
    }
}

# Django itself cannot serve static files if DEBUG=False.
# A simple fix is to just add the whitenoise middleware.
MIDDLEWARE += [ 'whitenoise.middleware.WhiteNoiseMiddleware' ]
