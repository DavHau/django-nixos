{ config, pkgs, ... }:
with pkgs;
import ../../default.nix rec {
  inherit pkgs;
  name = "djangoproject";
  keys-file = toString "/run/keys/django-keys";  # path created by NixOps
  settings = "djangoproject.settings_nix";
  src = "${../djangoproject}";
} // {
  # We upload the keys-file via NixOps' keys feature
  deployment.keys = {
    django-keys = {
      keyFile = ../django-keys; 
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}