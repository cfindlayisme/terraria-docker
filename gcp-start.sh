#!/bin/bash
#
# Start script handler for GCP terraria-docker image
#
# Author: Chuck Findlay <chuck@findlayis.me>
# License: LGPL v3.0

# Start cron so it runs auto backups
# TODO: pass env variables for GCS account and project to cron somehow? Or does it manage to make it here?
cron

# Check for service account key
if [ ! -f /config/gcs-key.json ]; then
    echo "No gcs-key.json file present for the GCS service account. Exiting!"
    exit 1
fi

# Authenticate to GCS
gcloud auth activate-service-account $GCS_ACCOUNT --key-file=/config/gcs-key.json --project=$GCS_PROJECT

# TODO: This should just pull from the backup for us, and only fail out of there isn't one available. Same goes for world
# Should have a flag though for the world so we can create one if we want first run (or just pop a warning if config exists but no world that it will autocreate)
if [ ! -f /config/serverconfig.txt ]; then
    echo "No serverconfig.txt file present. Exiting!"
    exit 1
fi

# Start terrara
/app/terraria/bin/TerrariaServer.bin.x86_64 -config /config/serverconfig.txt

# TODO: We need to save cleanly to GCP after the TerrariaServer process exits