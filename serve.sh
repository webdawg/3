#!/usr/bin/env bash
# Standardized dev server for this project. Always binds to the same port so
# the URL is predictable — override with PORT=xxxx ./serve.sh if 8123 is busy.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
PORT="${PORT:-8123}"
echo "Solar System Network dev server: http://localhost:${PORT}/index.html"
exec python3 -m http.server "$PORT" --bind 127.0.0.1
