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

# We're using a python module to server static files. Scared of it?
# Read here: http://whitenoise.evans.io/en/stable/index.html#infrequently-asked-questions
MIDDLEWARE += [ 'whitenoise.middleware.WhiteNoiseMiddleware' ]
STATICFILES_STORAGE = 'whitenoise.storage.CompressedStaticFilesStorage'
