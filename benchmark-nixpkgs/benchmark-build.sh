#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true mkDerivation.nix' \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true runCommandNoCC.nix' \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true builtin-derivation.nix'
