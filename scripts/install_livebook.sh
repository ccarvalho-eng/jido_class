#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.mix/escripts:$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH"

if ! command -v mix >/dev/null 2>&1; then
  echo "mix was not found on PATH. Install Elixir via asdf first." >&2
  exit 1
fi

echo "Installing Livebook with the local asdf-managed Elixir toolchain..."
mix escript.install hex livebook --force

if command -v asdf >/dev/null 2>&1; then
  asdf reshim elixir
fi

echo
echo "Livebook installed."
echo "Run it from this repo with:"
echo "  ./scripts/livebook.sh server livebooks"
