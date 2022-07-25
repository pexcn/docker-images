#!/bin/sh

#_get_container_id_by_name() {
#  local container_name="$1"
#  curl --silent --unix-socket /var/run/docker.sock -X GET "http://localhost/containers/json?filters=%7B%22name%22%3A%5B%22${container_name}%22%5D%7D" |
#    tr '{,' '\n' |
#    grep -i '"id":' |
#    head -n 1 |
#    cut -d '"' -f 4
#}

#_restart_container_by_id() {
#  local container_name="$1"
#  local container_id="$(_get_container_id_by_name $container_name)"
#  curl --silent --unix-socket /var/run/docker.sock -X POST http://localhost/containers/${container_id}/restart
#}

_restart_container_by_name() {
  local container_name="$1"
  curl --silent --unix-socket /var/run/docker.sock -X POST http://localhost/containers/${container_name}/restart
}

for container_name in "$@"; do
  _restart_container_by_name "$container_name"
done
