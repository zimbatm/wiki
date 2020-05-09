with import <nixpkgs> { };
runCommand "inside" { } ''
  echo FOO > $out
''
