#!/usr/bin/env bash
set -euo pipefail

rm -f busybox

nix build nixpkgs.busybox-sandbox-shell

cp -v ./result/bin/busybox .

rm -f ./result
