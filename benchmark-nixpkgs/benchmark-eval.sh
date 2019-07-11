#!/usr/bin/env bash
set -eup pipefail

hyperfine --warmup 3 \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval cc.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval no-cc.nix' \
  'nix-instantiate --option allow-unsafe-native-code-during-evaluation true --eval raw.nix'
