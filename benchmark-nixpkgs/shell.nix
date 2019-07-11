{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [
    pkgs.mdsh
    pkgs.hyperfine
  ];
}
