{
  network.description = "Django Example Deployment";

  webserver =
    { config, pkgs, ... }:
    { imports = [
        <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
        ./minimal.nix
      ];
      boot.loader.grub.device = "/dev/sda";
      fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
      boot.cleanTmpDir = true;
      networking.hostName = "django-example";
      networking.firewall.allowPing = true;
      services.openssh.enable = true;
      users.users.root.openssh.authorizedKeys.keys = [
        "your_ssh_key" 
      ];
      deployment.targetHost = "123.123.123.123";
    };
}