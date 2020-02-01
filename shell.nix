with import ./nix;
mkShell {
  buildInputs = [
    bundix
    github-pages
    mdsh
    niv
    nixpkgs-fmt
  ];

  shellHook = ''
    export NIX_PATH=nixpkgs=${path}
  '';
}
