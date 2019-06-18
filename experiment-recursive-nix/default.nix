with import <nixpkgs> {};
runCommand
"recursive-nix"
{ buildInputs = [ nix ]; }
''
  NIX_PATH=nixpkgs=${pkgs.path} nix-build ${./inner.nix} > $out
''
