#!/bin/bash

#TOKEN=$(ssh -oStrictHos_tKeyChecking=no root@$HOST "cat /var/lib/rancher/k3s/server/node-token")

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
}

function parse_input() {
  # jq reads from stdin so we don't have to set up any inputs, but let's validate the outputs
  eval "$(jq -r '@sh "export HOST=\(.controller)"')"
  if [[ -z "${HOST}" ]]; then export HOST=none; fi
}

function produce_output() {
  TOKEN=$(ssh -oStrictHostKeyChecking=no root@$HOST "cat /var/lib/rancher/k3s/server/node-token")
  jq -n \
    --arg token "$TOKEN" \
    '{"token":$token}'
}

check_deps && \
parse_input && \
sleep 30 && \
produce_output
