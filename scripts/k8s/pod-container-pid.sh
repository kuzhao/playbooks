#!/bin/bash

################
#Dependency:
#  crictl,pstree
#  containerd service up and running
#Code logic:
# The chain of search goes like:
# POD_NAME -> PID_PAUSE -> PID_POD_SHIM -> []PID_CONTAINERS
################

function fail {
	echo "$1"
	exit 1
}

# Start from the given arg of pod name, first get the pod's parent containerd-shim processID
POD_ID=$(chroot /host crictl pods | grep -v NotReady | grep $1 | awk '{print $1}')
[[ ! -z $POD_ID ]] && POD_PAUSE_PID=$(chroot /host crictl inspectp $POD_ID | jq '.info.pid') || fail "Pod $1 not found"

[[ ! -z $POD_PAUSE_PID ]] && POD_PPID=$(pstree -pTs $POD_PAUSE_PID | tr '(' '\n' | tail -n 2 | head -n 1 | awk -F ')' '{print $1}') || fail "No /pause found for $1"
[[ -z $POD_PPID ]] && fail "Error in finding the containershim process for pod $1"

# Loop through the direct children of the containerd-shim
for PROC_CMD in $(ps -ef | grep $POD_PPID | grep -v 'containerd-shim\|grep\|/pause' | awk '{print $2 "#" $8}');
do
	[[ -z $PROC_CMD ]] && fail "No PID found for one of the container processes in pod $1, container-shim PID $POD_PPID"
	# Get Hash number of the container under its PID through runc
	CONTAINER_HASH=$(runc --root /run/containerd/runc/k8s.io list | grep "$(echo $PROC_CMD|cut -d '#' -f 1) " | awk '{print $1}' | cut -c 1-13);
	CONTAINER_NAME=$(crictl ps | grep $CONTAINER_HASH | awk '{print $7}');
	echo "PID: $(echo $PROC_CMD|cut -d '#' -f 1), containerName: $CONTAINER_NAME, cmdName: $(echo $PROC_CMD|cut -d '#' -f 2)";
done
