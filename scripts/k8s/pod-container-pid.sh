#!/bin/bash

################
#Dependency:
#  crictl,pstree
#  containerd service up and running
#Code logic:
# The chain of search goes like:
# ALL_CONTAINERS -> grep target pod -> find PID via crictl inspect
################

function fail {
	echo "$1"
	exit 1
}

crictl ps -o json | jq -r '.containers[] | [.id, .labels."io.kubernetes.pod.name", .metadata.name] | @tsv' | grep $1 | while read -r container_id pod_name container_name; do pid=$(crictl inspect "$container_id" | jq -r '.info.pid'); echo "Container: $container_name, Pod: $pod_name, PID: $pid"; done
