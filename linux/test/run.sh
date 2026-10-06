#!/usr/bin/env bash
# Run the installer smoke test in Docker. Usage: linux/test/run.sh [extra install.sh args...]
set -euo pipefail
cd "$(dirname "$0")/../.."
docker build -q -t dotfiles-test -f linux/test/Dockerfile . >/dev/null
if [[ $# -gt 0 ]]; then docker run --rm --network host dotfiles-test bash -lc "cd ~/dotfiles/linux && ./install.sh $*"
else docker run --rm dotfiles-test; fi
