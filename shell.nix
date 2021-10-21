{ system ? builtins.currentSystem
, inputs ? import ./nix/sources.nix
, pkgs ? import ./nix { inherit system; }
, emanote ? import inputs.emanote
}:
