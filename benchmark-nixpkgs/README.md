# Measuring the overhead of nixpkgs

I am curious to find out how much overhead all that machines in nixpkgs is
adding to the build time. Let's find out.

## Three versions

### Nixpkgs with C compiler

[$ cc.nix](cc.nix)
```
let
  pkgs = import <nixpkgs> {
    config = {};
    overlays = [];
  };
  # get a precise timestamp for the benchmarks
  now = builtins.exec ["date" "+\"%s.%N\""];
in
  pkgs.runCommandCC "run-command-cc" {} ''
    echo ${now} > $out
  ''
```
### Nixpkgs without the C compiler

[$ no-cc.nix](no-cc.nix)
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
### And finally a raw version

[$ raw.nix](raw.nix)
```
# First run ./get-sandbox-shell to get the static busybox
let
  system = builtins.currentSystem;
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
We also need to fetch a static busybox build since we didn't bootstrap any
build environment.

[$ get-sandbox-shell.sh]()

`$ ./get-sandbox-shell.sh`
```
'./result/bin/busybox' -> './busybox'
```
## Benchmark time!

### Eval time

First, let's find out how much evaluation is taking in the build time:

[$ benchmark-eval.sh](benchmark-eval.sh)
```
#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval cc.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval no-cc.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval raw.nix'
```
`$ ./benchmark-eval.sh`
```
Benchmark #1: nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval cc.nix
  Time (mean ± σ):      96.8 ms ±   1.9 ms    [User: 83.7 ms, System: 13.3 ms]
  Range (min … max):    94.4 ms … 102.6 ms    29 runs
 
Benchmark #2: nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval no-cc.nix
  Time (mean ± σ):      96.4 ms ±   1.7 ms    [User: 84.8 ms, System: 11.9 ms]
  Range (min … max):    93.4 ms … 100.1 ms    30 runs
 
Benchmark #3: nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval raw.nix
  Time (mean ± σ):      16.8 ms ±   0.8 ms    [User: 12.3 ms, System: 4.8 ms]
  Range (min … max):    15.7 ms …  20.5 ms    167 runs
 
Summary
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval raw.nix' ran
    5.73 ± 0.29 times faster than 'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval no-cc.nix'
    5.76 ± 0.30 times faster than 'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval cc.nix'
```
### Instantiate time

[$ benchmark-drv.sh](benchmark-drv.sh)
```
#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true cc.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true no-cc.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true raw.nix'
```
`$ ./benchmark-drv.sh`
```
Benchmark #1: nix-instantiate --option allow-unsafe-native-code-during-evaluation true cc.nix
  Time (mean ± σ):     242.2 ms ±   6.4 ms    [User: 170.0 ms, System: 28.8 ms]
  Range (min … max):   235.3 ms … 260.7 ms    12 runs
 
Benchmark #2: nix-instantiate --option allow-unsafe-native-code-during-evaluation true no-cc.nix
  Time (mean ± σ):     240.4 ms ±   5.7 ms    [User: 172.6 ms, System: 26.6 ms]
  Range (min … max):   233.4 ms … 255.4 ms    12 runs
 
Benchmark #3: nix-instantiate --option allow-unsafe-native-code-during-evaluation true raw.nix
  Time (mean ± σ):      43.5 ms ±  10.0 ms    [User: 18.7 ms, System: 9.2 ms]
  Range (min … max):    30.6 ms …  67.1 ms    81 runs
 
Summary
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true raw.nix' ran
    5.53 ± 1.28 times faster than 'nix-instantiate --option allow-unsafe-native-code-during-evaluation true no-cc.nix'
    5.57 ± 1.30 times faster than 'nix-instantiate --option allow-unsafe-native-code-during-evaluation true cc.nix'
```
### Build time

Now let's see how long it takes to build the whole thing:

[$ benchmark-build.sh](benchmark-build.sh)
```
#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true cc.nix' \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true no-cc.nix' \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true raw.nix'
```
`$ ./benchmark-build.sh`
```
Benchmark #1: nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true cc.nix
  Time (mean ± σ):      1.618 s ±  0.117 s    [User: 205.8 ms, System: 35.6 ms]
  Range (min … max):    1.479 s …  1.853 s    10 runs
 
Benchmark #2: nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true no-cc.nix
  Time (mean ± σ):      1.547 s ±  0.120 s    [User: 193.4 ms, System: 33.3 ms]
  Range (min … max):    1.382 s …  1.735 s    10 runs
 
Benchmark #3: nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true raw.nix
  Time (mean ± σ):      1.042 s ±  0.122 s    [User: 23.5 ms, System: 12.3 ms]
  Range (min … max):    0.728 s …  1.177 s    10 runs
 
Summary
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true raw.nix' ran
    1.48 ± 0.21 times faster than 'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true no-cc.nix'
    1.55 ± 0.21 times faster than 'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true cc.nix'
```
## Analysis

TODO

## Want to reproduce the example?

1. Get a copy of the wiki from https://github.com/zimbatm/wiki
2. Enter this folder
3. Run `nix-shell --run mdsh`
