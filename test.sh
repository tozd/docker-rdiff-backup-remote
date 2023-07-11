#!/bin/sh

set -e

cleanup_openssh=0
cleanup_docker=0
cleanup_key=0
cleanup_network=0
cleanup() {
  set +e

  if [ "$cleanup_openssh" -ne 0 ]; then
    echo "Logs OpenSSH server"
    docker logs openssh

    echo "Stopping OpenSSH server Docker image"
    docker stop openssh
    docker rm -f openssh
  fi

  if [ "$cleanup_docker" -ne 0 ]; then
    echo "Logs"
    docker logs test

    echo "Stopping Docker image"
    docker stop test
    docker rm -f test
  fi

  if [ "$cleanup_key" -ne 0 ]; then
    rm -rf test/.ssh/backup_rsa* test/.ssh/backup_rsa* test/.ssh/known_hosts
  fi

  if [ "$cleanup_network" -ne 0 ]; then
    echo "Removing Docker network"
    docker network rm testnet
  fi
}

trap cleanup EXIT

echo "Creating Docker network"
time docker network create testnet
cleanup_network=1

# apk add --no-cache openssh-client
ssh-keygen -f test/.ssh/backup_rsa -N ""
cleanup_key=1

echo "Running OpenSSH server image"
docker run -d --name openssh --network testnet -e PUID=1000 -e PGID=1000 -e SUDO_ACCESS=true -e USER_NAME=user -e PUBLIC_KEY_DIR=/ssh -p 2222:2222 -v "$(pwd)/test/.ssh:/ssh" linuxserver/openssh-server:9.3_p1-r3-ls121
cleanup_openssh=1

echo "Sleeping"
sleep 5

echo "Installing rdiff-backup into OpenSSH server image"
docker exec openssh apk add --no-cache rdiff-backup

echo "Running Docker image"
docker run -d --name test --network testnet -v "$(pwd)/test:/config" -e "RDIFF_BACKUP_SOURCE=user@openssh::/" "${CI_REGISTRY_IMAGE}:${TAG}"
cleanup_docker=1

echo "Obtaining host key"
docker exec test ssh-keyscan -p 2222 openssh > test/.ssh/known_hosts

echo "Testing"
docker exec test /etc/cron.daily/backup
for file in /backup/etc /backup/rdiff-backup-data ; do
  docker exec test bash -c "[ -e '$file' ] || echo '$file is missing'"
done
