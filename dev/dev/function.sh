#!/usr/bin/env bash
# shellcheck disable=SC2155

_log() {
  local level=$1
  local color=$2
  local fd=$3
  local time=$(date '+%F %T')
  shift 3

  [[ -z "${NO_COLOR:-}" && -t "$fd" ]] || color=

  printf '%b[%s] [%s]: %b%s\n' "$color" "$time" "$level" \
    "${color:+\e[0m}" "$*" >&"$fd"
}

info() {
  _log INFO '\e[0;32m' 1 "$@"
}

warn() {
  _log WARN '\e[1;33m' 2 "$@"
}

error() {
  _log ERROR '\e[0;31m' 2 "$@"
}

export -f \
  _log \
  info \
  warn \
  error
