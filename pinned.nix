args: import (builtins.fetchTarball {
  # Descriptive name to make the store path easier to identify
  name = "nixos-19.03-beta";
  # Commit hash for nixos-unstable as of 2018-09-12
  # Might want to change this to be an actual commit?
  url = https://github.com/NixOS/nixpkgs/archive/19.03-beta.tar.gz;
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "1wr6dzy99rfx8s399zjjjcffppsbarxl2960wgb0xjzr7v65pikz";
}) args
