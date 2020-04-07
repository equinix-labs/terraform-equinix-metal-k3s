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
    k3s kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml && \
    k3s kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml && \
    k3s kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" && \
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
        wget https://raw.githubusercontent.com/packethost/csi-packet/master/deploy/kubernetes/controller.yaml
}

function start_anycast {
	apt update; apt install -y bird ; \
	while true; do \
		if [ ! -f /root/create_bird_conf.sh ]; then \
			echo "Bird not ready...waiting..."
		else
			bash /root/create_bird_conf.sh "${anycast_ip}"
			break
		fi
	done
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
kubectl config get-contexts && \
echo "Cluster controller spinup complete...setting up Bird..." && \
echo "Starting script for ${anycast_ip}..." ; \
start_anycast
