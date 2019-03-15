ifndef VERBOSE
.SILENT:
endif

define-cluster:
	if [ -z $(facility) ]; then \
		echo "Command format:\n\tmake facility=\"ewr1\" cluster_id=\"some_name\" define-cluster\n\n"; exit 1; fi
	echo "\n#Cluster $(cluster_id) in ${facility} generated `date +%F%H%M%S`\n" | tee -a 3-cluster-inventory.tf > /dev/null ; \
	cat template.tpl | sed -e 's|REGION|${facility}|g' -e 's|NAME|$(cluster_id)|g' | tee -a 3-cluster-inventory.tf > /dev/null ; \
	echo "\nCluster Name: cluster_$(cluster_id)_${facility}\nRun \`make cluster_name='cluster_$(cluster_id)_${facility}' apply-cluster\` to apply changes.\n"
apply-cluster:
	if [ -z $(cluster_name) ]; then \
		echo "\n\n Command format:\n\tmake cluster_name=\"cluster_id_facility\" spinup-cluster\n\n"; exit 1; fi
	terraform validate ; \
	terraform init ; \
	terraform apply -target="module.$(cluster_name)"
