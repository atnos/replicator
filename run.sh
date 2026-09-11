#!/bin/bash

# Exit when any command fails
set -e

if [ -z "$APPSIGNAL_APP_PUSH_API_KEY" ]
then
  echo "APPSIGNAL_APP_PUSH_API_KEY is not set"
  exit 1
fi

# One-off containers are ephemeral and have no sudo: install appsignal-wrap
# into /app/bin, which is writable and already in $PATH on Scalingo.
mkdir -p /app/bin
curl -sSL https://github.com/appsignal/appsignal-wrap/releases/latest/download/install.sh \
  | APPSIGNAL_RUN_INSTALL_FOLDER=/app/bin sh
export PATH="/app/bin:$PATH"

appsignal-wrap replicator --cron -- bash /app/replicate.sh
