#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true mkDerivation.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true runCommandNoCC.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true builtin-derivation.nix'
