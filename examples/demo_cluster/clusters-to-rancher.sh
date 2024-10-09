#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "Usage: $0 -p <password>"
	exit 1
}

die() {
	echo ${1} 1>&2
	exit ${2}
}

prechecks() {
	command -v kubectl >/dev/null 2>&1 || die "Error: kubectl not found" 1
	command -v curl >/dev/null 2>&1 || die "Error: curl not found" 1
	command -v jq >/dev/null 2>&1 || die "Error: jq not found" 1
	command -v scp >/dev/null 2>&1 || die "Error: scp not found" 1
}

wait_for_rancher() {
	while ! curl -k "${RANCHERURL}/ping" >/dev/null 2>&1; do sleep 1; done
}

bootstrap_rancher() {
	# Get token
	TOKEN=$(curl -sk -X POST ${RANCHERURL}/v3-public/localProviders/local?action=login -H 'content-type: application/json' -d "{\"username\":\"admin\",\"password\":\"${RANCHERPASS}\"}" | jq -r .token)

	# Set password
	curl -q -sk ${RANCHERURL}/v3/users?action=changepassword -H 'content-type: application/json' -H "Authorization: Bearer ${TOKEN}" -d "{\"currentPassword\":\"${RANCHERPASS}\",\"newPassword\":\"${PASSWORD}\"}"

	# Create a temporary API token (ttl=60 minutes)
	APITOKEN=$(curl -sk ${RANCHERURL}/v3/token -H 'content-type: application/json' -H "Authorization: Bearer ${TOKEN}" -d '{"type":"token","description":"automation","ttl":3600000}' | jq -r .token)

	# Set the Rancher URL
	curl -q -sk ${RANCHERURL}/v3/settings/server-url -H 'content-type: application/json' -H "Authorization: Bearer ${APITOKEN}" -X PUT -d "{\"name\":\"server-url\",\"value\":\"${RANCHERURL}\"}"
}

get_cluster_kubeconfig() {
	cluster="${1}"
	FIRSTHOST=$(echo ${OUTPUT} | jq -r "first(.clusters_output.value.cluster_details[\"${cluster}\"].nodes[].node_public_ipv4)")
	API=$(echo ${OUTPUT} | jq -r ".clusters_output.value.cluster_details[\"${cluster}\"].api")
	KUBECONFIG="$(mktemp)"
	export KUBECONFIG
	scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${FIRSTHOST}:/root/.kube/config ${KUBECONFIG}
	# Linux
	[ "$(uname -o)" == "GNU/Linux" ] && sed -i "s/127.0.0.1/${API}/g" ${KUBECONFIG}
	# OSX
	[ "$(uname -o)" == "Darwin" ] && sed -i "" "s/127.0.0.1/${API}/g" ${KUBECONFIG}
	chmod 600 ${KUBECONFIG}
	echo ${KUBECONFIG}
}

clusters_to_rancher() {
	RANCHERKUBE=$(get_cluster_kubeconfig "${RANCHERCLUSTER}")

	IFS=$'\n'
	for clustername in ${OTHERCLUSTERS}; do
		export KUBECONFIG=${RANCHERKUBE}
		normalizedname=$(echo ${clustername} | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]/-/g' | sed 's/ /-/g' | sed 's/^-*\|-*$/''/g')
		cat <<-EOF | kubectl apply -f - >/dev/null 2>&1
			apiVersion: provisioning.cattle.io/v1
			kind: Cluster
			metadata:
			  name: ${normalizedname}
			  namespace: fleet-default
			spec: {}
		EOF
		MANIFEST="$(kubectl get clusterregistrationtokens.management.cattle.io -n "$(kubectl get clusters.provisioning.cattle.io -n fleet-default "${normalizedname}" -o jsonpath='{.status.clusterName}')" default-token -o jsonpath='{.status.manifestUrl}')"
		DESTKUBECONFIG=$(get_cluster_kubeconfig "${clustername}")
		curl --insecure -sfL ${MANIFEST} | kubectl --kubeconfig ${DESTKUBECONFIG} apply -f - >/dev/null 2>&1
		rm -f "${DESTKUBECONFIG}"
	done

	rm -f "${RANCHERKUBE}"
}

PASSWORD=""
while getopts ":p:" opt; do
	case $opt in
	p)
		PASSWORD=$OPTARG
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		usage
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		usage
		;;
	esac
done

if [ -z "$PASSWORD" ]; then
	echo "Error: Password is required." 1>&2
	usage
fi

if [ ${#PASSWORD} -lt 12 ]; then
	die "Error: Password must be at least 12 characters long." 1
fi

[ ! -f "./terraform.tfstate" ] && die "Error: ./terraform.tfstate does not exist." 1

OUTPUT=$(terraform output -json)

[ "${OUTPUT}" == "{}" ] && die "Error. terraform output is '{}'." 1

RANCHERCLUSTER=$(echo ${OUTPUT} | jq -r 'first(.clusters_output.value.rancher_urls | keys[])')
RANCHERURL=$(echo ${OUTPUT} | jq -r ".clusters_output.value.rancher_urls[\"${RANCHERCLUSTER}\"].rancher_url")
RANCHERPASS=$(echo ${OUTPUT} | jq -r ".clusters_output.value.rancher_urls[\"${RANCHERCLUSTER}\"].rancher_initial_password_base64" | base64 -d)
OTHERCLUSTERS=$(echo ${OUTPUT} | jq -r ".clusters_output.value.cluster_details | keys[] | select(. != \"${RANCHERCLUSTER}\")")

prechecks
wait_for_rancher
bootstrap_rancher
clusters_to_rancher
