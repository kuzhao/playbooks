#!/bin/bash

# Start from the given arg of pod name, first get the pod's parent containerd-shim processID
POD_ID=$(crictl pods | grep -v NotReady | grep $1 | awk '{print $1}')
POD_PAUSE_PID=$(crictl inspectp $POD_ID | jq '.info.pid')
POD_PPID=$(pstree -pTs $POD_PAUSE_PID | tr '(' '\n' | tail -n 2 | head -n 1 | awk -F ')' '{print $1}')

# Loop through the direct children of the containerd-shim
for PROC_CMD in $(ps -ef | grep $POD_PPID | grep -v 'containerd-shim\|grep' | grep -v '/pause' | awk '{print $2 "#" $8}');
do
	# Get Hash number of the container under its PID through runc
	CONTAINER_HASH=$(runc --root /run/containerd/runc/k8s.io list | grep $(echo $PROC_CMD|cut -d '#' -f 1) | awk '{print $1}' | cut -c 1-13);
	CONTAINER_NAME=$(crictl ps | grep $CONTAINER_HASH | awk '{print $7}');
	echo "PID: $(echo $PROC_CMD|cut -d '#' -f 1), containerName: $CONTAINER_NAME, cmdName: $(echo $PROC_CMD|cut -d '#' -f 2)";
done
