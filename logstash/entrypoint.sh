#!/bin/bash
set -euo pipefail

# add custom commands here

# exec upstream entrypoint / command
exec /usr/local/bin/docker-entrypoint "$@"