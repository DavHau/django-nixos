{ config, pkgs, ... }:
with pkgs;
import ../../default.nix rec {
  inherit pkgs;
  name = "djangoproject";
  keys-file = toString ../django-keys;
  settings = "djangoproject.settings_nix";
  src = "${../djangoproject}";
} // {
  networking.firewall.allowedTCPPorts = [ 80 ];
}