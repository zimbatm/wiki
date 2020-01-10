let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {
    config = {};
    overlays = [];
  };
in
  pkgs.mkShell {
    buildInputs = [
      # tool to do some drawing
      pkgs.xournal
      # OBS streaming tool
      pkgs.obs-studio

      pkgs.cool-retro-term

      pkgs.grim
    ];

    shellHook = ''
      export XDG_CONFIG_HOME=$PWD/config
      mkdir -p config/obs-studio/plugins/
      ln -sfT ${pkgs.obs-wlrobs}/share/obs/obs-plugins/wlrobs config/obs-studio/plugins/wlrobs
    '';
  }
