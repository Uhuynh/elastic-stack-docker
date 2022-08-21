#!/bin/bash
set -euo pipefail

OUTPUT_FILE=/opt/config/elasticsearch.keystore
NATIVE_FILE=/usr/share/elasticsearch/config/elasticsearch.keystore

# --------------------------------------------------------
# if Azure storage credentials do not exist then something
# went wrong with the env setup
if [ -z ${AZURE_ACCOUNT_NAME:-} ] || [ -z ${AZURE_ACCOUNT_KEY:-} ]; then
    echo "Required env var does not exist. Aborting. Please check the env setup process."
    exit 1
fi

echo "check file"
# Exit if keystore already exists
if [[ -f "$OUTPUT_FILE" ]]; then
  echo "Elasticsearch keystore exists. Exiting"
  exit 0
fi

# --------------------------------------------------------
# generate keystore (without password) and add settings
bin/elasticsearch-keystore create
(echo "$AZURE_ACCOUNT_NAME" | bin/elasticsearch-keystore add -x 'azure.client.default.account')
(echo "$AZURE_ACCOUNT_KEY" | bin/elasticsearch-keystore add -x 'azure.client.default.key')
echo "Listing secrets in elasticsearch.keystore ..."
bin/elasticsearch-keystore list

echo "Saving new elasticsearch.keystore ..."
mkdir -p "$(dirname $OUTPUT_FILE)"
mv $NATIVE_FILE $OUTPUT_FILE
chmod 0644 $OUTPUT_FILE
chown -v 1000 $OUTPUT_FILE
ls -l $OUTPUT_FILE

echo "Setup keystore done!"