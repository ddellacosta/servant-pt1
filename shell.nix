{ nixpkgs ? import ./pinned.nix {}, compiler ? "ghc863" }:

let
  inherit (nixpkgs) pkgs;
  hpkgs = pkgs.haskell.packages.${compiler};
in
(hpkgs.callCabal2nix "servant-pt1" ./. {}).env.overrideAttrs(drv: {
  buildInputs = drv.buildInputs ++ [ hpkgs.cabal-install pkgs.dhall pkgs.postgresql ];
})
