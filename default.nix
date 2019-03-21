{ nixpkgs ? import ./pinned.nix {}, compiler ? "ghc863" }:
(nixpkgs.pkgs.haskell.packages.${compiler}.callCabal2nix "servant-pt1" ./. {})
