# Nix Flakes edition

> **NOTE**: This is an experimental version of Nix. Things might break.

Nix Flakes is an experimental branch of the Nix project that adds dependency
management and a central entry-point to Nix projects.

Here are some notes that I took for myself on the subject.

## Changelog

A non-strict history of things that are happening. Latest in front.

* 2020-11-17: Allow nix.conf options to be set in flake.nix. 343239fc8a1993f707a990c2cd54a41f1fa3de99
* 2020-09-18: Add --redirect flag to redirect dependencies. f9438fb64a223c05ebcfffa9706e1ca811a87d70
* 2020-08-05: `nix eval <INSTALLABLE> --start-repl-on-eval-errors`. [e5662b](https://github.com/NixOS/nix/commit/e5662ba6525c27248d57d8265e9c6c3a46f95c7e)
* 2020-07-31: Introduce `nix bundle nixpkgs#jq` which can be used to build installable bundles. [#3880](https://github.com/NixOS/nix/pull/3880)
* 2020-07-28: Nix version bumped from 2.4 to 3.0 [189e6f5](https://github.com/NixOS/nix/commit/189e6f5e1d949f50ab0b6e5acd25e230d206692d)
* 2020-07-16: `nix diff-closures <drv1> <drv2>` that shows package version changes between two profiles. [#3818](https://github.com/NixOS/nix/pull/3818_
* Nix Flakes was merged into master.

## Other sources

* https://edolstra.github.io/talks/nixcon-oct-2019.pdf
* https://nixos.wiki/wiki/Flakes
* https://www.tweag.io/blog/2020-05-25-flakes/
* https://www.tweag.io/blog/2020-06-25-eval-cache/
* https://www.tweag.io/blog/2020-07-31-nixos-flakes/

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
* `nixConfig` allows to set per-project Nix configuration.
* `input` is an attribute set of all the dependencies of the flake. The schema
  is described below.
* `output` is a function of one argument that takes an attribute set of all
  the realized inputs, and outputs another attribute set which schema is
  described below.

### nixConfig schema

Eg (from the commit message):
```
{
  nixConfig.bash-prompt-suffix = "ngi# ";
  nixConfig.substituters = [ "https://cache.ngi0.nixos.org/" ];
}
```

### Input schema

This is not a complete schema but should be enough to get you started:

```nix
{
  inputs.bar = {
    # Source of the input. It supports `github:` `gitlab:` and a number of
    # other schemes
    url = "github:foo/bar/branch";
    # Turn off if the target is not a flake.
    flake = false;
    # Used to override inputs of the target if it is a flake.
    inputs = {
      # For example, here we declare to use the same version as the parent
      # nixpkgs. It's probably also possible to override the URL attribute.
      nixpkgs.follows = "nixpkgs";
    };
  };
}
```

The `bar` input is then passes to the 

### Output schema

Here is what I found out while reading [`src/nix/flake.cc`](https://github.com/NixOS/nix/blob/master/src/nix/flake.cc) in `CmdFlakeCheck`.

Where:
* `<system>` is something like "x86_64-linux".
* `<machine>` is something like "mymachine".
* `<attr>` is an attribute name like "hello".
* `<job>` is a hydra job name like "release".
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
  # TODO: Same idea as overlay but several.
  overlays."<attr>" = final: prev: { };
  # TODO: Not sure how it's being used
  nixosModule = TODO;
  # TODO: Same idea as nixosModule but several
  nixosModules."<attr>" = TODO;
  # TODO: Not sure how it's being used
  nixosConfigurations."<machine>" = TODO;
  # TODO: Similar idea as for nixosModules but for hydra jobs.
  hydraJobs."<job>" = TODO;
  # Used by `nix flake init -t <flake>`
  defaultTemplate = {
    path = "<store-path>";
    description = "template description goes here?";
  };
  # Used by `nix flake init -t <flake>#<attr>`
  templates."<attr>" = { path = "<store-path>"; description = ""; );
}
```
See also:
* https://github.com/NixOS/nix/blob/master/src/nix/flake-check.md

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

## How to build specific attributes in a flake repository?

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

## Some file is not found

Flakes only takes files into account if they are either in the git tree.
You don't necessarily have to commit the files, adding them in the git staging
area with `git add` is enough.

## Pure evaluation

Because the evaluation in Flakes is "pure", a few things are disabled.

Pure evaluation can also be enabled by using `--option pure-eval true` on
standard nix CLIs. Eg:

```console
$ nix-instantiate --option pure-eval true --eval --expr '(builtins.currentTime)'
error: --- EvalError -------------------------------------------------------------- nix-instantiate
at: (1:2) from string

     1| (builtins.currentTime)
      |  ^

attribute 'currentTime' missing
```

To find these out I searched for `evalSettings.pureEval` in the
"src/libexpr" folder of the Nix repo.

All these builtins are not defined in pure evaluation:

* `builtins.currentTime -> int`
* `builtins.currentSystem -> str`

Some more special behaviours:

* `builtins.getEnv str -> str` returns empty strings.
* `builtins.storePath` throws `'__storePath' is not allowed in pure evaluation mode`
* `builtins.filterSource` and `builtins.path` has some condition in it, I
  don't know exactly which.
* `builtins.fetchTree` also has some conditions.
* `<foo>` throws `cannot look up '<foo>' in pure evaluation mode (use'--impure' to override)`

## Running unfree packages

Because Flakes are pure by default, something like `nix run nixpkgs#steam`
will complain that it's unfree, even if `NIXPKGS_ALLOW_UNFREE=1` is set in the
environment.

The workaround is to disable the pure evaluation with the `--impure` flag like
so:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#steam
```
