#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.mix/escripts:$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH"

if ! command -v livebook >/dev/null 2>&1; then
  echo "livebook is not installed for the current toolchain." >&2
  echo "Run ./scripts/install_livebook.sh first." >&2
  exit 1
fi

exec livebook "$@"
