# Measuring the overhead of nixpkgs

I am curious to find out how much overhead all that machinery in nixpkgs is
adding to the build time compared to a pure Nix derivation. Let's find out.

TL;DR: skip to the [Findings](#findings) section.

## Three versions

### `pkgs.stdenv.mkDerivation`

Here we are using the standard nixpkgs `stdenv.mkDerivation` that most
packages are using in nixpkgs.

[$ mkDerivation.nix](mkDerivation.nix)
```
let
  pkgs = import <nixpkgs> {
    config = {};
    overlays = [];
  };
  # get a precise timestamp for the benchmarks
  now = builtins.exec ["date" "+\"%s.%N\""];
in
  pkgs.stdenv.mkDerivation {
    name = "run-command-cc";
    # don't unpack since there is no source
    unpackPhase = ":";
    installPhase = ''
      echo ${now} > $out
    '';
  }
```
Note that I had to use the experimental `builtins.exec` to inject a unique
value for each builds to invalidate and force a rebuild on each run. There is also
`builtins.currentTime` but it doesn't work on a tight benchmark loop because
the precision is up to the second. `builtins.exec` is only available when
running nix with the `--option allow-unsafe-native-code-during-evaluation
true` flag.

### `pkgs.runCommandNoCC`

There is a lighter builder in nixpkgs that doesn't have all the C Compiler
overhead. Does it make the builds any faster?

[$ runCommandNoCC.nix](runCommandNoCC.nix)
```
let
  pkgs = import <nixpkgs> {
    config = {};
    overlays = [];
  };
  now = builtins.exec ["date" "+\"%s.%N\""];
in
  pkgs.runCommandNoCC "run-command-no-cc" {} ''
    echo ${now} > $out
  ''
```
### And finally a version made only from the builtins

[$ builtin-derivation.nix](builtin-derivation.nix)
```
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
```
We also need to fetch a static busybox shell since we didn't bootstrap any
build environment.

`$ ./get-busybox.sh`
```
'./result/bin/busybox' -> './busybox'
```
## Benchmark time!

Okay so now, equipped with out test scripts, let's measure a few things:

### Eval time

First, let's find out how much evaluation is taking in the build time:

[$ benchmark-eval.sh](benchmark-eval.sh)
```
#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval mkDerivation.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval runCommandNoCC.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval builtin-derivation.nix'
```
`$ ./benchmark-eval.sh`
```
Benchmark #1: nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval mkDerivation.nix
  Time (mean ± σ):     102.4 ms ±  11.7 ms    [User: 88.3 ms, System: 14.1 ms]
  Range (min … max):    95.4 ms … 156.9 ms    30 runs
 
Benchmark #2: nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval runCommandNoCC.nix
  Time (mean ± σ):      97.3 ms ±   2.4 ms    [User: 85.4 ms, System: 12.0 ms]
  Range (min … max):    93.3 ms … 102.9 ms    30 runs
 
Benchmark #3: nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval builtin-derivation.nix
  Time (mean ± σ):      16.6 ms ±   4.0 ms    [User: 11.8 ms, System: 4.7 ms]
  Range (min … max):    15.6 ms …  62.7 ms    168 runs
 
Summary
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval builtin-derivation.nix' ran
    5.85 ± 1.42 times faster than 'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval runCommandNoCC.nix'
    6.16 ± 1.65 times faster than 'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval mkDerivation.nix'
```
### Instantiate time

Next up is evaluation + instantiation of the .drv file that describes the
build.

[$ benchmark-drv.sh](benchmark-drv.sh)
```
#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true mkDerivation.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true runCommandNoCC.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true builtin-derivation.nix'
```
`$ ./benchmark-drv.sh`
```
Benchmark #1: nix-instantiate --option allow-unsafe-native-code-during-evaluation true mkDerivation.nix
  Time (mean ± σ):     251.0 ms ±  10.2 ms    [User: 176.3 ms, System: 33.5 ms]
  Range (min … max):   236.5 ms … 263.8 ms    12 runs
 
Benchmark #2: nix-instantiate --option allow-unsafe-native-code-during-evaluation true runCommandNoCC.nix
  Time (mean ± σ):     243.3 ms ±   8.1 ms    [User: 173.8 ms, System: 27.0 ms]
  Range (min … max):   234.3 ms … 257.5 ms    12 runs
 
Benchmark #3: nix-instantiate --option allow-unsafe-native-code-during-evaluation true builtin-derivation.nix
  Time (mean ± σ):      47.2 ms ±   9.5 ms    [User: 21.4 ms, System: 10.4 ms]
  Range (min … max):    32.2 ms …  68.1 ms    46 runs
 
Summary
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true builtin-derivation.nix' ran
    5.16 ± 1.05 times faster than 'nix-instantiate --option allow-unsafe-native-code-during-evaluation true runCommandNoCC.nix'
    5.32 ± 1.09 times faster than 'nix-instantiate --option allow-unsafe-native-code-during-evaluation true mkDerivation.nix'
```
### Build time

And finally the whole build cycle:

[$ benchmark-build.sh](benchmark-build.sh)
```
#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true mkDerivation.nix' \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true runCommandNoCC.nix' \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true builtin-derivation.nix'
```
`$ ./benchmark-build.sh`
```
Benchmark #1: nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true mkDerivation.nix
  Time (mean ± σ):      1.604 s ±  0.086 s    [User: 182.0 ms, System: 30.8 ms]
  Range (min … max):    1.494 s …  1.769 s    10 runs
 
Benchmark #2: nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true runCommandNoCC.nix
  Time (mean ± σ):      1.559 s ±  0.150 s    [User: 179.6 ms, System: 29.3 ms]
  Range (min … max):    1.363 s …  1.745 s    10 runs
 
Benchmark #3: nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true builtin-derivation.nix
  Time (mean ± σ):      1.118 s ±  0.119 s    [User: 16.6 ms, System: 6.9 ms]
  Range (min … max):    0.974 s …  1.351 s    10 runs
 
Summary
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true builtin-derivation.nix' ran
    1.39 ± 0.20 times faster than 'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true runCommandNoCC.nix'
    1.43 ± 0.17 times faster than 'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true mkDerivation.nix'
```
## Findings

nixpkgs adds a ~6x overhead to evaluation of a single derivation. It's
important to note that this might be reduced when evaluating multiple builds
at the same time.

`pkgs.runCommandNoCC` is marginally faster than `stdenv.mkDerivation`.
Changing builds in nixpkgs to use it is probably not worth the effort.

A build takes at least 1 second in all the scenarios. This is quite a massive
overhead for doing almost nothing. This is with the nix client talking to the
daemon and the daemon running the build inside of a sandbox.

## Future work

It would be interesting to trace the nix evaluation in nixpkgs and find out
what is adding to the evaluation time exactly.

It would be interesting to run sysdig or some other system-level performance
tool to figure out what the daemon is doing exactly during the builds.

## Want to reproduce the example?

1. Get a copy of the wiki from https://github.com/zimbatm/wiki
2. Enter this folder
3. Run `nix-shell --run mdsh`
