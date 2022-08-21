#!/bin/bash
set -euo pipefail

# load secrets from vault
secrets --log=/tmp/secrets.log load --underscore --quote --to-stdout --vault-credential=identity --vault=dje-svc-elk-bd8c --vault-custom-hosts-allowed > /opt/setup/.env.tmp

# source temp environment vars
export $(grep -v '^#' /opt/setup/.env.tmp | xargs)

# cleanup
rm /opt/setup/.env.tmp

# exec upstream entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"