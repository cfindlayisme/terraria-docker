Simple vanilla terraria server image. Designed to be tiny.

You simply need to mount the volume /config and put two files in it:
- serverconfig.txt
- yourworld (and specify /config/yourworld to use it)

Note there is also a Dockerfile-GCP. This image is designed for usage with Google Cloud Services for auto backup/import of the world and server configuration. Allows me to create & destroy container instances on GCS for the odd day I'm playing with friends.