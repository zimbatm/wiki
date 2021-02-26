{ system ? builtins.currentSystem
, pkgs ? import ./nix { inherit system; }
}:
pkgs.mkShell {
  buildInputs = [
    pkgs.mdsh
    pkgs.nixpkgs-fmt
  ];

  shellHook = ''
    export NIX_PATH=nixpkgs=${toString ./nix}
  '';
}
