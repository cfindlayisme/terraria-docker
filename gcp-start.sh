#!/bin/bash
#
# Start script handler for GCP terraria-docker image
#
# Author: Chuck Findlay <chuck@findlayis.me>
# License: LGPL v3.0

echo "0 */6 * * * gcloud auth activate-service-account --key-file=/config/gcs-key.json && gsutil cp /config/World.wld gs://$GCS_BUCKET$GCS_BUCKET_PATH/World.wld" > /etc/cron.d/gcs-hourly-backup
chmod 0644 /etc/cron.d/gcs-hourly-backup
crontab /etc/cron.d/gcs-hourly-backup

# Start cron so it runs auto backups
cron

# Check for service account key
if [ ! -f /config/gcs-key.json ]; then
    echo "No gcs-key.json file present for the GCS service account. Exiting!"
    exit 1
fi

# Authenticate to GCS
gcloud auth activate-service-account --key-file=/config/gcs-key.json

# Check for serverconfig - and exit if we cannot get it
if [ ! -f /config/serverconfig.txt ]; then
    if gsutil cp gs://$GCS_BUCKET$GCS_BUCKET_PATH/serverconfig.txt /config/serverconfig.txt; then
        echo "Grabbed serverconfig.txt from GCS bucket since it did not exist locally!"
    else
        echo "No serverconfig.txt file present here or in cloud bucket. Exiting!"
        exit 1
    fi
fi

# Check for world. Don't need to fail badly though if it isn't there
if [ ! -f /config/World.wld ]; then
    if gsutil cp gs://$GCS_BUCKET$GCS_BUCKET_PATH/World.wld /config/World.wld; then
        echo "Grabbed World.wld from GCS bucket since it did not exist locally!"
    else
        echo "World.wld does not exist locally or in the bucket, so lets hope you have auto-generation enabled."
    fi
fi

# URL to hit on startup - for example, to trigger a dynamic DNS update on google domains
if [ ! -z "$CURL_STARTUP" ]; then
    curl -4 $CURL_STARTUP
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

if [ ! -z "$CURL_CLOSE" ]; then
    curl -4 $CURL_CLOSE
fi
