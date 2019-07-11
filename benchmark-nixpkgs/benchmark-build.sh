#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true cc.nix' \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true no-cc.nix' \
  'nix-build --no-out-link --option allow-unsafe-native-code-during-evaluation true raw.nix'
