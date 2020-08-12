# Nix Flakes edition

> **NOTE**: This is an experimental version of Nix. Things might break.

Nix Flakes is an experimental branch of the Nix project that adds dependency
management and a central entry-point to Nix projects.

Here are some notes that I took for myself on the subject.

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

> **NOTE**: flake makes a strong assumption that the folder is a git
  repository. It doesn't work outside of them.

In your repo, run `nix flake init` to generate the `flake.nix` file. Then run
`git add flake.nix` to add it to the git staging area, otherwise nix will not
recognize that the file exists.

TODO: add more usage examples here.

See also https://www.tweag.io/blog/2020-05-25-flakes/

## Flake schema

The `flake.nix` file is a Nix file but that has special restrictions (more on
that later).

It has 3 top-level attributes:

* `description` which is self...describing
* `input` is an attribute set of all the dependencies of the flake. The schema
  is described below.
* `output` is a function of one argument that takes an attribute set of all
  the realized inputs, and outputs another attribute set which schema is
  described below.

### Input schema

This is not a complete schema but should be enough to get you started:

```nix
{
  inputs.bar = { url = "github:foo/bar/branch"; flake = false; }
}
```

The `bar` input is then passes to the 

### Output schema

Here is what I found out while reading [`src/nix/flake.cc`](https://github.com/NixOS/nix/blob/master/src/nix/flake.cc) in `CmdFlakeCheck`.

Where:
* `<system>` is something like "x86_64-linux".
* `<attr>` is an attribute name like "hello".
* `<flake>` is a flake name like "nixpkgS".
* `<store-path>` is a /nix/store.. path

```nix
{ self, ... }@inputs:
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

## Building NixOS configurations with Flakes

There is a special, undocumented way to build NixOS configurations with
flakes.

First, change `flake.nix` to output a configuration. This uses the
`nixosConfigurations` key. The `nixpkgs` flake includes a helper for that:

```nix
{
  outputs = { nixpkgs, ... }: {
    nixosConfigurations.mymachine = nixpkgs.lib.nixosSystem {
      modules = [
        # Point this to your original configuration.
        ./machines/mymachine/configuration.nix
      ];
      # Select the target system here.
      system = "x86_64-linux";
    };
  };
}
```

Then to switch configurations, use `nixos-rebuild --flake .#mymachine switch`,
from the same repository where the `flake.nix` file is located.

To switch a remote configuration, use:
```sh
nixos-rebuild --flake .#mymachine \
  --target-host mymachine-hostname --build-host localhost \
  switch
```

> **NOTE**: Remote building seems to be broken at the moment, which is why the
  build host is set to "localhost".

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

And finally, run `nix develop`. This is what replaces the old `nix-shell`
invocation.

Exit and run again, this command should now be super fast.

> **NOTE**: TODO: there is an alternative version where the `defaultPackage` is a
  `pkgs.buildEnv` that contains all the dependencies. And then `nix shell` is
  used to open the environment.

## Direnv integration

Assuming that the flake defines a `devShell` output attribute and that you are
using [direnv](https://direnv.net). Here is how to replace the old
`use nix` stdlib function with the faster flake version:

[$ use_flake.sh](use_flake.sh) as sh
```sh
use_flake() {
  watch_file flake.nix
  watch_file flake.lock
  eval "$(nix print-dev-env)"
}
```

Copy this in `~/.config/direnv/lib/use_flake.sh` or in
`~/.config/direnv/direnvrc`

With this in place, you can now replace the `use nix` invocation in the
`.envrc` file with `use flake`.

The nice thing about this approach is that evaluation is cached.

### Optimize the reloads

Nix Flakes has a Nix evaluation caching mechanism. Is it possible to expose
that somehow to automatically trigger direnv reloads?

With the previous solution, direnv would only reload iff the flake.nix or
flake.lock files have changed. This is not completely precise as the flake.nix
file might import other files in the repository.

## Using with GitHub Actions

See https://github.com/numtide/nix-flakes-installer#github-actions

## Pushing Flake inputs to Cachix

Flake inputs can also be cached in the Nix binary cache!

```sh
nix flake archive --json \
  | jq -r '.path,(.inputs|to_entries[].value.path)' \
  | cachix push $cache_name
```

### How to build specific attributes in a flake repository?

When in the repository top-level, run `nix build .#<attr>`. It will look in
the `legacyPackages` and `packages` output attributes for the corresponding
derivation.

Eg, in nixpkgs:
 
```
nix build .#hello
```

## Building all the derivations of a flake

Traditionally we would run `nix-build ci.nix` or something equivalent but
flakes only support pointing `nix build` to a single derivation.

I am not 100% confident on this answer: it looks like exposing the derivation
in the `checks` output attribute, and then running `nix flake check` does the
trick.

### Some file is not found

Flakes only takes files into account if they are either in the git tree.
You don't necessarily have to commit the files, adding them in the git staging
area with `git add` is enough.
