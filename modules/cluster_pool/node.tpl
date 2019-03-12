#!/bin/bash

function configure_kube() {
	curl -sfL https://get.k3s.io | sh - 
}

function join_cluster {
	systemctl stop k3s ; \
	sed -i "s/k3s server/k3s agent --server https:\/\/${primary_node_ip}:6443 --token $(cat /root/node-token)/g" /etc/systemd/system/k3s.service ; \
	systemctl daemon-reload ; \
	systemctl start k3s
}

function node_token {
	while true; do \
		if [ ! -f /root/node-token ]; then \
			echo "Node-token not ready...rechecking in 20 seconds..." ; \
			sleep 20
		else
			echo "Node-token ready...proceeding with K3s configuration..." ; \
			break
		fi
	done
}

sleep 180 ; \
configure_kube ; \
node_token ; \
echo "Joining cluster ${primary_node_ip} with token: $(cat /root/node-token)" ; \
join_cluster
