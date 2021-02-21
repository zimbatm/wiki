{ pkgs ? import ./nix { } }:
with pkgs;
mkShell {
  buildInputs = [
    mdsh
    nixpkgs-fmt
  ];

  shellHook = ''
    export NIX_PATH=nixpkgs=${toString ./nix}
  '';
}
