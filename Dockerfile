ARG ffmpeg_source=jrottenberg/ffmpeg
ARG ffmpeg_tag=4.4-ubuntu
ARG radarr_tag=latest
ARG extra_packages
FROM ${ffmpeg_source}:${ffmpeg_tag} as ffmpeg

RUN \
  mkdir -p /build

FROM lscr.io/linuxserver/radarr:${radarr_tag}
LABEL maintainer="mdhiggins <mdhiggins23@gmail.com>"

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/
COPY --from=ffmpeg /build /

ENV SMA_PATH /usr/local/sma
ENV SMA_RS Radarr
ENV SMA_UPDATE false
ENV SMA_HWACCEL true

RUN \
# make directory
  mkdir ${SMA_PATH} && \
# ffmpeg
  chgrp users /usr/local/bin/ffmpeg && \
  chgrp users /usr/local/bin/ffprobe && \
  chmod g+x /usr/local/bin/ffmpeg && \
  chmod g+x /usr/local/bin/ffprobe

EXPOSE 7878

VOLUME /config
VOLUME /usr/local/sma/config

# update.py sets FFMPEG/FFPROBE paths, updates API key and Sonarr/Radarr settings in autoProcess.ini
COPY extras/ ${SMA_PATH}/
COPY root/ /
