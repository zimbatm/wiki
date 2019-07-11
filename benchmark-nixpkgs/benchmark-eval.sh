#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval mkDerivation.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval runCommandNoCC.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval builtin-derivation.nix'
