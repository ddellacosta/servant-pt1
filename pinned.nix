args: import (builtins.fetchTarball {
  # Descriptive name to make the store path easier to identify
  name = "nixos-19.03";
  # Commit hash for nixos-unstable as of 2018-09-12
  url = https://github.com/NixOS/nixpkgs/archive/19.03.tar.gz;
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "0q2m2qhyga9yq29yz90ywgjbn9hdahs7i8wwlq7b55rdbyiwa5dy";
}) args
