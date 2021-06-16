#!/usr/bin/env bash

BASE_DIR=$(pwd)

for dir in $(find . -name "docker-compose.yml" | xargs dirname); do
  cd $dir
  docker-compose pull --include-deps
  docker-compose up -d --remove-orphans
  docker image prune -af
  cd $BASE_DIR
done
