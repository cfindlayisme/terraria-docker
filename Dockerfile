# Re-do of https://github.com/cfindlayisme/docker-terraria from scratch which is a fork of https://github.com/kaysond/docker-terraria
#
# Using buster-slim for an image to shrink things. Tried to do alpine 3.16 but it was a no-go due to libc issues (Oct 2022)
#
# Author: Chuck Findlay <chuck@findlayis.me>
# License: LGPL v3.0

FROM debian:11.6-slim

ARG version="1449"
LABEL maintainer="chuck@findlayis.me"

ADD "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${version}.zip" /tmp/terraria.zip
RUN \
 echo "**** Install terraria ****" && \
 apt update && \
 apt install -y unzip screen && \
 mkdir -p /root/.local/share/Terraria && \
 echo "{}" > /root/.local/share/Terraria/favorites.json && \
 mkdir -p /app/terraria/bin && \
 unzip /tmp/terraria.zip ${version}'/Linux/*' -d /tmp/terraria && \
 mv /tmp/terraria/${version}/Linux/* /app/terraria/bin && \
 chmod +x /app/terraria/bin/TerrariaServer.bin.x86_64 && \
 rm -rf /tmp/terraria /tmp/terraria.zip && \
 apt remove -y unzip && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/tmp/*

# Port and the volume for the config + world
EXPOSE 7777
VOLUME ["/config"]

CMD /app/terraria/bin/TerrariaServer.bin.x86_64 -config /config/serverconfig.txt
