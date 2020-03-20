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
};
in
{
  imports = [ django ];
  networking.firewall.allowedTCPPorts = [ 80 ];
}