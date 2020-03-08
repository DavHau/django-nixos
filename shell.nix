let
  nixpkgs-src = import ./nixpkgs-src.nix;
  pkgs = import nixpkgs-src { config = {}; };
  python = (import ./python.nix {inherit pkgs;});
in
pkgs.mkShell {
  buildInputs = [
    python
    pkgs.nixops
  ];
  shellHook = ''
    export NIX_PATH="nixpkgs=${nixpkgs-src}:."
    export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
  '';
}
