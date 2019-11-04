let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {
    config = {};
    overlays = [];
  };
in
  pkgs.mkShell {
    buildInputs = [
      pkgs.obs-studio
    ];

    shellHook = ''
      export XDG_CONFIG_HOME=$PWD/config
      mkdir -p config/obs-studio/plugins/
      ln -sfT ${pkgs.obs-wlrobs}/share/obs/obs-plugins/wlrobs config/obs-studio/plugins/wlrobs
    '';
  }
