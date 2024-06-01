Simple vanilla terraria server image. Designed to be tiny.

You simply need to mount the volume /config and put two files in it:
- serverconfig.txt
- World.wld (and specify /config/World.wld to use it)

Example to run:

    docker run -it -p 7777:7777 -v /home/user/terraria:/config ghcr.io/cfindlayisme/terraria-docker:latest

Note there is also a Dockerfile-GCP. This image is designed for usage with Google Cloud Services for auto backup/import of the world and server configuration. Allows me to create & destroy container instances on GCS for the odd day I'm playing with friends. It does not require running on GCP itself, just a bucket to put the config & world into. 

Example to run this version:

    docker run -it -p 7777:7777 -e GCS_BUCKET=bucket -e GCS_BUCKET_PATH=/terraria -v /home/user/terraria:/config ghcr.io/cfindlayisme/terraria-docker:gcp

This assumes that you have /config/gcs-key.json with a service account setup for it to use. You can export this from IAM service accounts in json key format.

Extra ENV variables:
- CURL_STARTUP=URL and CURL_CLOSE=url
  - URLs to hit with curl on startup and exit. Ie, in my case so my dynamic google DNS updates for me
    - CURL_STARTUP=https://user:password@domains.google.com/nic/update?hostname=hostname
    - CURL_CLOSE=https://user:password@domains.google.com/nic/update?hostname=hostname&offline=yes

Note I do not have public images for this as that would include files I have no copyright to. So, to use this, you'll have to build the images yourself.

TODO: Mod support