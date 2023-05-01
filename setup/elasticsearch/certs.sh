#!/bin/bash
set -euo pipefail

# generate Certificate Authority (CA) certificate
if [[ ! -f /certs/ca/ca.crt ]]; then
  echo "Creating Certificate Authority..."
  bin/elasticsearch-certutil ca --silent --pem -out /certs/ca.zip
  unzip /certs/ca.zip -d /certs
  rm /certs/ca.zip
else
  echo "Certificate Authority exists. Skipping"
fi

# generate certs and keys for Elasticsearch nodes, signed by previously created CA
if [[ ! -f /certs/es/es.crt ]]; then
  echo "Creating certs..."
  echo -ne \
  "instances:\n"\
  "  - name: es\n"\
  "    dns:\n"\
  "      - es\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  > /certs/instances.yml
  bin/elasticsearch-certutil cert --silent --pem -out /certs/certs.zip --in /certs/instances.yml --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key;
  unzip /certs/certs.zip -d /certs;
  rm /certs/certs.zip;
else
  echo "Elasticsearch node certificates already exist. Skipping"
  exit 0
fi

# set files and directories permissions
echo "Setting file permissions"
chown -R root:root /certs;
find . -type d -exec chmod 750 \{\} \;;
find . -type f -exec chmod 640 \{\} \;;
echo "Setup certs done!"