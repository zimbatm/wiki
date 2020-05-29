{
  description = "Personal wiki & journal";

  inputs.utils.url = "github:numtide/flake-utils";

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
