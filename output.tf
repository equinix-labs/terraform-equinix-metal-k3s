output "K3s Regions Created" {
	value = "Check spin-up status on each facility cluster controller:\n\t kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes -w \nTroubleshooting:\n\ttail -n 250 /var/log/cloud-init-output.log\n\nAllow 5-10 minutes for cluster to complete spin-up."
}
