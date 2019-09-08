# args: import (builtins.fetchTarball {
#   # Descriptive name to make the store path easier to identify
#   name = "nixos-19.03";
#   # Commit hash for nixos-unstable as of 2018-09-12
#   url = https://github.com/NixOS/nixpkgs/archive/19.03.tar.gz;
#   # Hash obtained using `nix-prefetch-url --unpack <url>`
#   sha256 = "0q2m2qhyga9yq29yz90ywgjbn9hdahs7i8wwlq7b55rdbyiwa5dy";
# }) args

args: import ((import <nixpkgs> {}).fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "61f0936d1cd73760312712615233cd80195a9b47";
  sha256 = "1fkmp99lxd827km8mk3cqqsfmgzpj0rvaz5hgdmgzzyji70fa2f8";
}) args
