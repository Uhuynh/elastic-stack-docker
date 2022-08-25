#!/bin/bash
set -euo pipefail

# generate Certificate Authority (CA)
if [[ ! -f /certs/ca/ca.crt ]]; then
  echo "Creating Certificate Authority..."
  bin/elasticsearch-certutil ca --pem -out /certs/ca.zip
  unzip /certs/ca.zip -d /certs
  rm /certs/ca.zip
else
  echo "Certificate Authority exists. Skipping"
fi

# generate certs and keys for Elasticsearch nodes, signed by previously created CA
if [[ ! -f /certs/es01/es01.crt ]]; then
  echo "Creating certs..."
  echo -ne \
  "instances:\n"\
  "  - name: es01\n"\
  "    dns:\n"\
  "      - es01\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  "  - name: es02\n"\
  "    dns:\n"\
  "      - es02\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  "  - name: es03\n"\
  "    dns:\n"\
  "      - es03\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  > /certs/instances.yml
  bin/elasticsearch-certutil cert --silent --pem -out /certs/certs.zip --in /certs/instances.yml --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key
  unzip /certs/certs.zip -d /certs
  rm /certs/certs.zip
else
  echo "Elasticsearch node certificates already exist. Skipping"
  exit 0
fi

# set files and directories permissions
echo "Setting file permissions..."
chown -R 1000:0 /certs
find /certs -type d -exec chmod 754 \{\} \;;
find /certs -type f -exec chmod 644 \{\} \;;
echo "Setup certs done!"