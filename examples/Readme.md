## Contents

### `./djangoproject`
Nearly untouched django project created via '`django-admin startproject djangoproject`'.  
Two changes have been made:
1. File `settings_nix.py` has been added which imports the default settings.py and adds the minimal required options necessary to be compatible to this project's nixos config. See parent dir's Readme for exact requirements for django settings
2. `urls.py` is modified to display the django admin page as frontpage. Otherwise we would get a `Not Found` error.

### `./nixos`
Example NixOS configuration files.
  - `minimal.nix`: How to use this project
  - `custom-python.nix`: How to add extra python modules
  - `nginx-letsencrypt-duckdns.nix`: Secure nginx config with forced encryption + automatic letsencrypt + dynamic dns

### `./nixops`  
  - `minimal.nix`: Equals `./nixos/minimal.nix` plus key management for NixOps. Extendable with examples from `./nixos`.
  - `hetznercloud.nix`: Concrete deployment example for a hetzner cloud instance which has been infected by https://github.com/elitak/nixos-infect