{ pkgs ? import ./nix {} }:
with pkgs;
mkShell {
  buildInputs = [
    bundix
    github-pages
    mdsh
    niv
    nixpkgs-fmt
  ];

  shellHook = ''
    export NIX_PATH=nixpkgs=${toString ./nix}
  '';
}
