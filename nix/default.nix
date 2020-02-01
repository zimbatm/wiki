let
  sources = import ./sources.nix;
  pkgs = import sources.nixpkgs {
    config = {};
    overlays = [ overlay ];
  };

  overlay = self: pkgs: {
    github-pages = pkgs.callPackage ./pkgs/github-pages {};
  };
in
  pkgs
