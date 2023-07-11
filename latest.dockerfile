FROM registry.gitlab.com/tozd/docker/cron:ubuntu-jammy

VOLUME /config
VOLUME /backup

ENV RDIFF_BACKUP_SOURCE=
ENV RDIFF_BACKUP_EXPIRE=12M

RUN apt-get update -q -q && \
  apt-get install rdiff-backup openssh-client --yes --force-yes && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./etc /etc
