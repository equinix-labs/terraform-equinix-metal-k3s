#!/bin/bash

function configure_kube() {
	curl -sfL https://get.k3s.io | sh - 
}

function join_cluster {
	systemctl stop k3s ; \
	sed -i 's/k3s server/k3s agent --server https:\/\/${primary_node_ip}:6443 --token ${kube_token}/g' /etc/systemd/system/k3s.service ; \
	systemctl daemon-reload ; \
	systemctl start k3s
}

sleep 180 ; \
configure_kube ; \
echo "Joining cluster ${primary_node_ip} with token: ${kube_token}" ; \
join_cluster
