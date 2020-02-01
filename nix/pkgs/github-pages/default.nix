{ lib, bundlerApp }:

bundlerApp {
  pname = "github-pages";
  gemdir = ./.;
  exes = [
    "github-pages"
    "jekyll"
  ];
}
