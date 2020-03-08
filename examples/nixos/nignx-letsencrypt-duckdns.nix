{ config, pkgs, ... }:
with pkgs;
import ../../default.nix rec {
  inherit pkgs;
  name = "djangoproject";
  keys-file = toString ../django-keys;
  settings = "djangoproject.settings_nix";
  src = "${../djangoproject}";
  port = 8000;
} // {
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  users.users.django = {
    home = "/home/django";
  };
  # nginx proxy
  services.nginx = {
    enable = true;
    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # reverse proxy with automatic letsencrypt
    virtualHosts."example.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:" + toString(8000) + "/";
    };
  };
  services.ddclient = {
    enable = true;
    protocol = "duckdns";
    password = "your_duckdns_token";
    domains = ["example.duckdns.org"];
  };
}