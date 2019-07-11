let
  pkgs = import <nixpkgs> {
    config = {};
    overlays = [];
  };
  now = builtins.exec ["date" "+\"%s.%N\""];
in
  pkgs.runCommandNoCC "run-command-no-cc" {} ''
    echo ${now} > $out
  ''
