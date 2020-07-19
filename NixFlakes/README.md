# Nix Flakes edition

> **NOTE**: This is an experimental version of Nix. Things might break.

Nix Flakes is an experimental branch of the Nix project that adds dependency
management and a central entry-point to Nix projects.

## Installation

### NixOS

Add the following options to the NixOS configuration:

<!-- [$ configuration.nix](configuration.nix) as nix -->
```nix
{ pkgs, ... }:
{
  # Install the flakes edition
  nix.package = pkgs.nixFlakes;
  # Enable the nix 2.0 CLI and flakes support feature-flags
  nix.extraOptions = ''
    experimental-features = nix-command flakes 
  '';
}
```

Then run `nixos-rebuild switch` and that's it.

### Other systems

Run `nix-env -iA nixFlakes` to replace Nix with the flakes edition.

Edit either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` and add:
```
experimental-features = nix-command flakes 
```
This is needed to expose the Nix 2.0 CLI and flakes support that are hidden
behind feature-flags.

Finally, if the Nix installation is in multi-user mode, don't forget to
restart the nix-daemon.

## Basic project usage

In your repo, run `nix flake init` to generate the `flake.nix` file. Then run
`git add flake.nix` to add it to the git staging area, otherwise nix will not
recognize that the file exists.

TODO: add more usage examples here.

TODO: explain the flake.nix schema.

See also https://www.tweag.io/blog/2020-05-25-flakes/

### Output schema

Here is what I found out while reading [`src/nix/flake.cc`](https://github.com/NixOS/nix/blob/master/src/nix/flake.cc) in `CmdFlakeCheck`.

Where:
* `<system>` is something like "x86_64-linux".
* `<attr>` is an attribute name like "hello".
* `<flake>` is a flake name like "nixpkgS".
* `<store-path>` is a /nix/store.. path

```nix
{
  # Executed by `nix flake check`
  checks."<system>"."<attr>" = derivation;
  # Executed by `nix build .#<name>`
  packages."<system>"."<attr>" = derivation;
  # Executed by `nix build .`
  defaultPackage."<system>" = derivation;
  # Executed by `nix run .#<name>
  apps."<system>"."<attr>" = {
    type = "app";
    program = "<store-path>";
  };
  defaultApp."<system>" = { type = "app"; program = "..."; };
  
  # TODO: Not sure how it's being used
  legacyPackages = TODO;
  # TODO: Not sure how it's being used
  overlay = final: prev: { };
  # TODO: Same idea as overlay but a list of them.
  overlays = [];
  # TODO: Not sure how it's being used
  nixosModule = TODO;
  # TODO: Same idea as nixosModule but a list of them.
  nixosModules = [];
  # TODO: Not sure how it's being used
  nixosConfigurations = TODO;
  # TODO: Same idea as nixosModule but a list of them.
  hydraJobs = TODO;
  # Used by `nix flake init -t <flake>`
  defaultTemplate = {
    path = "<store-path>";
    description = "template description goes here?";
  };
  # Used by `nix flake init -t <flake>#<attr>`
  templates."<attr>" = { path = "<store-path>"; description = ""; );
}
```

## Super fast nix-shell

One of the nix feature of the Flake edition is that Nix evaluations are
cached.

Let's say that your project has a `shell.nix` file that looks like this:

[$ shell.nix](shell.nix) as nix
```nix
{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    nixpkgs-fmt
  ];

  shellHook = ''
    # ...
  '';
}
```

Running `nix-shell` can be a bit slow and take 1-3 seconds.

Now create a `flake.nix` file in the same repository:

[$ flake.nix](flake.nix) as nix
```nix
{
  description = "my project description";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShell = import ./shell.nix { inherit pkgs; };
        }
      );
}
```

Run `git add flake.nix` so that Nix recognizes it.

And finally, run `nix dev-shell`. This is what replaces the old `nix-shell`
invocation.

Exit and run again, this command should now be super fast.

## Direnv integration

If you are using [direnv](https://direnv.net), here is how to replace the old
`use nix` stdlib function with the faster flake version:

[$ use_flake.sh](use_flake.sh) as sh
```sh
use_flake() {
  watch_file flake.nix
  watch_file flake.lock
  eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
}
```

Copy this in `~/.config/direnv/lib/use_flake.sh` or in
`~/.config/direnv/direnvrc`

With this in place, you can now replace the `use nix` invocation in the
`.envrc` file with `use flake`.

The nice thing about this approach is that evaluation is cached, and that the
project's shell is now protected from the nix garbage-collector.

## Using with GitHub Actions

https://github.com/numtide/nix-flakes-installer#github-actions

## Pushing Flake inputs to cachix

Flake inputs can also be cached in the Nix binary cache!

```sh
nix flake archive --json \
  | jq -r '.path,(.inputs|to_entries[].value.path)' \
  | cachix push $cache_name
```

## FAQ

* Q: How to build specific attributes in a flake repository?
* A: Use `nix build .#<attr>`. Eg: `nix build .#hello`.
