builtins.fetchGit {
  name = "nixpkgs-for-craifty";
  url = https://github.com/nixos/nixpkgs-channels/;
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-19.09`
  ref = "refs/heads/nixos-19.09";
  rev = "dca7ec628e55307ac4b46f00f3be09464fcf4f4b";
}