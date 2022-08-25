#!/bin/bash
set -euo pipefail

# exec upstream entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"