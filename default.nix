{ nixpkgs ? import ./pinned.nix {}, compiler ? "ghc864" }:
(nixpkgs.pkgs.haskell.packages.${compiler}.callCabal2nix "servant-pt1" ./. {})
