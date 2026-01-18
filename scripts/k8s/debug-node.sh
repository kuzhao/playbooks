#!/bin/bash

IMG='mcr.microsoft.com/mirror/docker/library/debian:bullseye-slim'

function fail {
	echo "$1"
	exit 1
}

# Test k8s cluster accessibility
if ! kubectl get node &>/dev/null; then
  echo "Kubernetes cluster is not accessible."
  exit 1
fi

# Exit 1 if there is no argument passed to the script
if [[ $# -eq 0 ]]; then
  echo "No arguments provided. Exiting."
  exit 1
fi
# Exit 1 if more than one arguments passed to the script
if [[ $# -gt 1 ]]; then
  echo "More than one arguments provided. Exiting."
  exit 1
fi

# Verify privileged pod can be deployed
kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep node-debugger | xargs kubectl delete pod
kubectl debug node/$1 --profile sysadmin --image $IMG -- sleep 120 || exit 1
sleep 10
kubectl get pod | grep node-debugger | grep Running \
  && echo 'Privileged pod validation passed' || fail 'Check the permission to create privilege pods'
kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep node-debugger | xargs kubectl delete pod

# File containing commands (one per line)
COMMAND_FILE="command.txt"
if [[ ! -f "$COMMAND_FILE" ]]; then
  echo "Command file '$COMMAND_FILE' not found."
  exit 1
fi

# For each command, create and apply a pod YAML
INDEX=1
while IFS= read -r CMD; do
  POD_NAME="cmd-$INDEX"
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
spec:
  volumes:
  - name: host-root
    hostPath:
      path: /
      type: ''
  containers:
  - name: debugger
    command: ["chroot", "/host", "bash", "-c", "$CMD"]
    image: $IMG
    securityContext:
      privileged: true
    volumeMounts:
    - name: host-root
      mountPath: /host
  hostIPC: true
  hostNetwork: true
  hostPID: true
  nodeName: $1
EOF
  echo "Applied pod $POD_NAME for command: $CMD"
  INDEX=$((INDEX+1))
done < "$COMMAND_FILE"