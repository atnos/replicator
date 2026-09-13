#!/bin/bash

# Exit when any command fails
set -e

if [ -z "$SOURCE_APP" ]
then
  echo "SOURCE_APP is not set"
  exit 1
fi

if [ -z "$SCALINGO_CLI_TOKEN" ]
then
  echo "SCALINGO_CLI_TOKEN is not set"
  exit 1
fi

install-scalingo-cli
dbclient-fetcher psql 16

scalingo login --api-token $SCALINGO_CLI_TOKEN

export ADDON_ID=`scalingo --app $SOURCE_APP addons | grep -i postgresql | awk -F '│' '{print $3}'`

if [ -z "$ADDON_ID" ]
then
  echo "Unable to find PostgreSQL addon ID for $SOURCE_APP"
  exit 1
fi

export ARCHIVE_NAME=backup.tar.gz

scalingo --app $SOURCE_APP --addon $ADDON_ID backups-download --output $ARCHIVE_NAME

export BACKUP_NAME=`tar -tf $ARCHIVE_NAME | tail -n 1`

tar -C /app -xvf $ARCHIVE_NAME

# spatial_ref_sys belongs to the PostGIS extension and cannot be written by
# the addon user: drop it from the restore list to avoid a permission error.
pg_restore --list /app$BACKUP_NAME | grep -v -E 'TABLE DATA public spatial_ref_sys|TABLE public spatial_ref_sys' > /app/restore.list

pg_restore --clean --if-exists --no-owner --no-privileges --no-comments --use-list /app/restore.list --dbname $DATABASE_URL /app$BACKUP_NAME
