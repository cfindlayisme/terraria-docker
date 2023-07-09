# Re-do of https://github.com/cfindlayisme/docker-terraria from scratch which is a fork of https://github.com/kaysond/docker-terraria
#
# Using buster-slim for an image to shrink things. Tried to do alpine 3.16 but it was a no-go due to libc issues (Oct 2022)
#
# Author: Chuck Findlay <chuck@findlayis.me>
# License: LGPL v3.0

FROM debian:bookworm-slim AS builder

ARG version="1449"
LABEL maintainer="chuck@findlayis.me"

ADD "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${version}.zip" /tmp/terraria.zip

RUN \
 apt update && \
 apt install -y unzip && \
 mkdir -p /app/terraria/bin && \
 unzip /tmp/terraria.zip ${version}'/Linux/*' -d /tmp/terraria && \
 mv /tmp/terraria/${version}/Linux/* /app/terraria/bin && \
 chmod +x /app/terraria/bin/TerrariaServer.bin.x86_64

FROM debian:bookworm-slim

RUN \
	mkdir -p /root/.local/share/Terraria && \
 	echo "{}" > /root/.local/share/Terraria/favorites.json

COPY --from=builder /app /app

# Port and the volume for the config + world
EXPOSE 7777
VOLUME ["/config"]

CMD /app/terraria/bin/TerrariaServer.bin.x86_64 -config /config/serverconfig.txt
