#!/usr/bin/env bash
# One entry point: runs mac/install.sh on macOS, linux/install.sh on Linux. All arguments are passed through.
#   git clone https://github.com/DucLong06/iTerm2.git ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "$(uname -s)" in
  Darwin) exec "$ROOT/mac/install.sh" "$@" ;;
  Linux)  exec "$ROOT/linux/install.sh" "$@" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
