#!/bin/bash
set -euo pipefail

#source <(secrets --log=/tmp/secrets.log load --vault dje-svc-elk-bd8c --underscore --export --quote --to-stdout)
secrets --log=/tmp/secrets.log load --underscore --quote --to-stdout --vault-credential=identity --vault=dje-svc-elk-bd8c --vault-custom-hosts-allowed > /opt/setup/.env.tmp

# show number of vars in .env
wc -l /opt/setup/.env.tmp

# source temp environment vars
export $(grep -v '^#' /opt/setup/.env.tmp | xargs)

# cleanup
rm /opt/setup/.env.tmp

if [ $SETUP_TASK = "es-keystore" ]; then
  /opt/setup/keystore.sh
elif [ $SETUP_TASK = "es-initialize" ]; then
  /opt/setup/initialize.sh
fi