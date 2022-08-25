#!/bin/bash
set -euo pipefail

# exec upstream entrypoint / command
exec /usr/local/bin/docker-entrypoint "$@"