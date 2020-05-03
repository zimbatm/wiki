{
  description = "Personal wiki & journal";
  edition = 201909;
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    devShell.x86_64-linux =
      let
        pkgs = import ./nix {
          inherit nixpkgs;
          system = "x86_64-linux";
        };
      in
      import ./shell.nix { inherit pkgs; };
  };
}
