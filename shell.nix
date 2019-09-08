{ nixpkgs ? import ./pinned.nix {}, compiler ? "ghc865" }:

let
  inherit (nixpkgs) pkgs;
  hpkgs = pkgs.haskell.packages.${compiler};
  servant-pt1 = pkgs.callPackage ./. {};
in
servant-pt1.overrideAttrs (drv: {
  buildInputs = drv.buildInputs ++ [ hpkgs.cabal-install pkgs.dhall pkgs.postgresql ];
})
