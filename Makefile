ifndef VERBOSE
.SILENT:
endif

define-cluster:
	if [ -z $(facility) ]; then \
		echo "Command format:\n\tmake facility=\"ewr1\" cluster_id=\"some_name\" define-cluster\n\n"; exit 1; fi
	cat template.tpl | sed -e 's|REGION|${facility}|g' -e 's|NAME|$(cluster_id)|g' | tee -a 2-clusters.tf

apply-cluster:
	if [ -z $(cluster_name) ]; then \
		echo "\n\n Command format:\n\tmake cluster_name=\"cluster_id_facility\" spinup-cluster\n\n"; exit 1; fi
	terraform validate ; \
	terraform apply -target="module.$(cluster_name)"
