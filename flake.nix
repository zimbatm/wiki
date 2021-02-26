{
  description = "Personal wiki & journal";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = import ./shell.nix { inherit system; };
    });
}
