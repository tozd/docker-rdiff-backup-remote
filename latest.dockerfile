FROM tozd/cron:ubuntu-xenial

VOLUME /config
VOLUME /backup

ENV RDIFF_BACKUP_SOURCE=
ENV RDIFF_BACKUP_EXPIRE 12M

RUN apt-get update -q -q && \
 apt-get install rdiff-backup openssh-client --yes --force-yes

COPY ./etc /etc
