#!/bin/bash

function init_cluster {
	curl -sfL https://get.k3s.io | sh - && \
	sleep 30 && \
	apt update; apt install -y tmux
}

function start_cluster {
	tmux new -s k3s -d "k3s server"
}

function check_cluster {
	sleep 60 ; \
	if [ -e /var/lib/rancher/k3s/server/node-token ]; then echo "Ready!"; else echo "node-token not present"; exit 1; fi
}

function metal_lb {
    echo "Configuring MetalLB for ${packet_network_cidr}..." && \
    cat << EOF > /var/lib/rancher/k3s/server/manifests/metal_lb.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: packet-public-network
      protocol: layer2
      addresses:
      - ${packet_network_cidr}
      auto-assign: false
EOF
}

function packet_csi_config {
  mkdir /root/kube ; \
  cat << EOF > /var/lib/rancher/k3s/server/manifests/packet-config.yaml
apiVersion: v1
kind: Secret
metadata:
  name: packet-cloud-config
  namespace: kube-system
stringData:
  cloud-sa.json: |
    {
    "apiKey": "${packet_auth_token}",
    "projectID": "${packet_project_id}"
    }
EOF
}

function apply_workloads {
        echo "Pulling configs for /var/lib/rancher/k3s/server/manifests..." && \
	cd /var/lib/rancher/k3s/server/manifests && \
        wget https://raw.githubusercontent.com/packethost/csi-packet/master/deploy/kubernetes/setup.yaml && \
        wget https://raw.githubusercontent.com/packethost/csi-packet/master/deploy/kubernetes/node.yaml && \
        wget https://raw.githubusercontent.com/packethost/csi-packet/master/deploy/kubernetes/controller.yaml && \ 
        wget https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
}

init_cluster && \
start_cluster && \
check_cluster && \
sleep 120 && \
apply_workloads && \
packet_csi_config && \
metal_lb && \
echo "MetalLB configured...\nTo allocate a Service with an IP from ${packet_network_cidr}, create Service with following annotation...\n\tmetallb.universe.tf/packet-public-network\n\nin your definition Metadata." ; \
echo "Finishing..." ; \
echo "Renaming context to $(hostname)..." && \
kubectl config rename-context default $(hostname) && \
kubectl config get-contexts
