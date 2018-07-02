#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"
rm -f "$HOME/vimwiki"
ln -s "$(pwd -P)" "$HOME/vimwiki"
