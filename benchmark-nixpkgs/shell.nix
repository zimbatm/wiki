{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs = [
    pkgs.coreutils
    pkgs.hyperfine
    pkgs.mdsh
  ];
}
