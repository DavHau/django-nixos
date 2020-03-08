{ config, pkgs, ... }:
with pkgs;
import ../../default.nix rec {
  inherit pkgs;
  name = "djangoproject";
  keys-file = toString ../django-keys;
  settings = "djangoproject.settings_nix";
  src = "${../djangoproject}";
  python = pkgs.python37.withPackages ( ps: with ps; [
    django_2_2
    whitenoise
    gunicorn
    psycopg2
    requests  # as an example we add requests
  ]);
}