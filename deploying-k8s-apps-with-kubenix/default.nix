{ app
, hostname
, imageTag
}@args:
let
  kubenix-src = builtins.fetchTarball {
    url = "https://github.com/xtruder/kubenix/archive/9acf125f74b9ce7d65b77f33294e65f275b5bc31.tar.gz";
    sha256 = "06z55z4zg8shim3zgkz7j7zkhb9cwm2da9wwh5sf3is7isgyh471";
  };
  kubenix = import kubenix-src { };
  configuration = import ./configuration.nix args;
  manifest = kubenix.buildResources {
    inherit configuration;
    writeJSON = false;
  };
in
manifest
