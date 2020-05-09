let
  pkgs = import <nixpkgs> {
    config = { };
    overlays = [ ];
  };
  # get a precise timestamp for the benchmarks
  now = builtins.exec [ "date" "+\"%s.%N\"" ];
in
pkgs.stdenv.mkDerivation {
  name = "run-command-cc";
  # don't unpack since there is no source
  unpackPhase = ":";
  installPhase = ''
    echo ${now} > $out
  '';
}
