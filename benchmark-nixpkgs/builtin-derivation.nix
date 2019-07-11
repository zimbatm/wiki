let
  system = builtins.currentSystem;
  # Run ./get-busybox to get a copy of the static busybox
  busybox = ./busybox;
  now = builtins.exec ["date" "+\"%s.%N\""];
in
  derivation {
    name = "raw";
    inherit system;
    builder = busybox;
    args = ["sh" "-c" "echo ${now} > $out"];
  }
