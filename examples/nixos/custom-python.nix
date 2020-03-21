{ config, pkgs, ... }:
with pkgs;
let django = (import (builtins.fetchGit {
      url = "https://github.com/DavHau/django-nixos";
      ref = "master";
      ### uncomment next line and enter newest commit of https://github.com/DavHau/django-nixos
      # rev = "commit_hash";
    })) {
  inherit pkgs;
  name = "djangoproject";
  keys-file = toString ../django-keys;
  settings = "djangoproject.settings_nix";
  src = "${../djangoproject}";
  python = pkgs.python37.withPackages ( ps: with ps; [
    django_2_2
    whitenoise
    brotli
    gunicorn
    psycopg2
    requests  # as an example we add requests
  ]);
};
in
{
  imports = [ django ];
}