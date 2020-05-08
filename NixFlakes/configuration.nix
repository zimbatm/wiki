{ pkgs, ... }:
{
  # install the flakes edition
  nix.package = pkgs.nixFlakes;
  # enable the nix 2.0 CLI and flakes support feature-flags
  nix.extraOptions = ''
    experimental-features = nix-command flakes 
  '';
}
