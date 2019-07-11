let
  pkgs = import <nixpkgs> {
    config = {};
    overlays = [];
  };
  # get a precise timestamp for the benchmarks
  now = builtins.exec ["date" "+\"%s.%N\""];
in
  pkgs.runCommandCC "run-command-cc" {} ''
    echo ${now} > $out
  ''
