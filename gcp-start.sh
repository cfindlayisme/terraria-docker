#!/bin/bash
#
# Start script handler for GCP terraria-docker image
#
# Author: Chuck Findlay <chuck@findlayis.me>
# License: LGPL v3.0

echo "@hourly gcloud auth activate-service-account --key-file=/config/gcs-key.json && gsutil cp /config/World.wld gs://$GCS_BUCKET$GCS_BUCKET_PATH/World.wld\n" > cron.d/gcs-hourly-backup
chmod 0644 /etc/cron.d/gcs-hourly-backup
crontab /etc/cron.d/gcs-hourly-backup

# Start cron so it runs auto backups
# TODO: pass env variables for GCS account and project to cron somehow? Or does it manage to make it here?
cron

# Check for service account key
if [ ! -f /config/gcs-key.json ]; then
    echo "No gcs-key.json file present for the GCS service account. Exiting!"
    exit 1
fi

# Authenticate to GCS
gcloud auth activate-service-account $GCS_ACCOUNT --key-file=/config/gcs-key.json

# Check for serverconfig - and exit if we cannot get it
if [ ! -f /config/serverconfig.txt ]; then
    if gsutil cp gs://$GCS_BUCKET$GCS_BUCKET_PATH/serverconfig.txt /config/serverconfig.txt; then
        echo "Grabbed config from GCS bucket since it did not exist locally!"
    else
        echo "No serverconfig.txt file present here or in cloud bucket. Exiting!"
        exit 1
    fi
fi

# Check for world. Don't need to fail badly though if it isn't there
if [ ! -f /config/World.wld ]; then
    if gsutil cp gs://$GCS_BUCKET$GCS_BUCKET_PATH/World.wld /config/World.wld; then
        echo "Grabbed config from GCS bucket since it did not exist locally!"
    else
        echo "World does not exist locally or in the bucket, so lets hope you have auto-generation enabled."
    fi
fi

# Start terrara
if /app/terraria/bin/TerrariaServer.bin.x86_64 -config /config/serverconfig.txt; then
    # Copy over to GCS once TerrariaServer is done
    gsutil cp /config/World.wld gs://$GCS_BUCKET$GCS_BUCKET_PATH/World.wld
    gsutil cp /config/serverconfig.txt gs://$GCS_BUCKET$GCS_BUCKET_PATH/serverconfig.txt
    echo "Server exited gracefully. Copied World.wld and serverconfig.txt to GCS bucket"
else
    echo "Server exited non-gracefully - not copying the world and server config to the GCP bucket"
fi