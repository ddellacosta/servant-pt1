{ nixpkgs ? import ./pinned.nix {}, compiler ? "ghc865" }:

let
  easy-ps = import (nixpkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "f1e038e20596512656413fd3c192f57ad4fc88d3";
    sha256 = "1lxi09fnlgq4bcbcdjml1lvcldkh0kaz8x09ayw2s8dz8pzkv7a6";
  });

  hkPkgs = nixpkgs.haskell.packages;
  servant-pt1 = hkPkgs.${compiler}.callCabal2nix "servant-pt1" ./. {};

in servant-pt1.env.overrideAttrs (drv: {
  buildInputs = drv.buildInputs ++ [
    easy-ps.purs
    easy-ps.spago
    easy-ps.psc-package2nix
    easy-ps.psc-package
    nixpkgs.nodejs-11_x
    nixpkgs.nginx
  ];
})
