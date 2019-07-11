# First run ./get-sandbox-shell to get the static busybox
let
  system = builtins.currentSystem;
  busybox = ./busybox;
  now = builtins.exec ["date" "+\"%s.%N\""];
in
  derivation {
    name = "raw";
    inherit system;
    builder = busybox;
    args = ["sh" "-c" "echo ${now} > $out"];
  }
