{ nixpkgs ? (import ./sources.nix).nixpkgs
, system ? builtins.currentSystem
}:
let
  pkgs = import nixpkgs {
    inherit system;
    config = {};
    overlays = [ overlay ];
  };

  overlay = self: pkgs: {
    github-pages = pkgs.callPackage ./pkgs/github-pages {};
  };
in
  pkgs
