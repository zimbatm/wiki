{
  description = "zimbatm's personal wiki";

  inputs.emanote.url = "github:srid/emanote";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils, emanote }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        devShell = pkgs.mkShell {
          packages = [
            emanote.defaultPackage.${system}
            pkgs.mdsh
            pkgs.nixpkgs-fmt
          ];

          shellHook = ''
            export NIX_PATH=nixpkgs=${nixpkgs}
          '';
        };
      });
}
