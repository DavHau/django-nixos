{ pkgs, ...}:
let
  python = pkgs.python37;
in
python.withPackages (ps: with ps; [
  django_2_2
  whitenoise  # for serving static files
  gunicorn  # for serving via http
  psycopg2  # for connecting to postgresql
])
