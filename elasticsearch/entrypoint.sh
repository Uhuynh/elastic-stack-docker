#!/bin/bash
set -euo pipefail

# add custom commands here

# exec upstream entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"