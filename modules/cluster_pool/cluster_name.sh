#!/bin/bash

#TOKEN=$(ssh -oStrictHos_tKeyChecking=no root@$HOST "cat /var/lib/rancher/k3s/server/node-token")

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it" ; \
  test -f $(which curl) || error_exit "curl command not detected in path, please install it"
}

function produce_output() {
  NAME=$(curl -s http://name.generator.gourmet.yoga | jq .name | sed -e 's|_|-|g') && \
  echo "{\"cluster_name\":$NAME}"
}

check_deps && \
produce_output
