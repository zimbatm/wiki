{
  description = "Personal wiki & journal";
  edition = 201909;

  inputs.utils.uri = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import ./nix {
            inherit nixpkgs;
            system = "x86_64-linux";
          };
        in
        {
          devShell = import ./shell.nix { inherit pkgs; };
        }
      );
}
