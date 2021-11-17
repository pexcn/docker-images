#!/usr/bin/env bash

BASE_DIR=$(pwd)

for dir in $(find . -name "docker-compose.yml" | xargs dirname); do
  cd $dir
  docker-compose pull --include-deps
  docker-compose up -d --remove-orphans
  cd $BASE_DIR
done

docker image prune -af
docker container prune -f
docker volume prune -f
