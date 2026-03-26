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
echo 'Use kubectl debug to test if you can create a privileged debug pod'
kubectl debug node/$1 --profile sysadmin --image $IMG -- sleep 120 || exit 1
sleep 10
kubectl get pod | grep node-debugger | grep Running \
  && echo 'Privileged pod create test passed' || fail 'Check the permission to create privilege pods'
kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep node-debugger | xargs kubectl delete pod

commands=(
    "iotop -btoP -d 5"
    'while true;do conntrack -L|grep -v \"168\\|169\";echo;sleep 5;done'
    'while true;do crictl ps -o json | jq -r '\''.containers[] | [.id, .labels.\"io.kubernetes.pod.name\", .metadata.name] | @tsv'\'' | while read -r container_id pod_name container_name; do pid=$(crictl inspect \"$container_id\" | jq -r '\''.info.pid'\''); echo \"Container: $container_name, Pod: $pod_name, PID: $pid\";pstree -pTs $pid; done;echo;sleep 15;done'
)
# Clear existing debuggers
echo 'Clean up residue debuggers'
kubectl delete pod -l app=debug-node
# Apply node debugging
# For each command, create and apply a pod YAML
INDEX=1
for cmd in "${commands[@]}"; do
  POD_NAME="nodedebugger-$INDEX"
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
  labels:
    app: debug-node
spec:
  volumes:
  - name: host-root
    hostPath:
      path: /
      type: ''
  containers:
  - name: debugger
    command: ["chroot", "/host", "bash", "-c", "$cmd"]
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
  echo "Applied pod $POD_NAME for command: $cmd"
  INDEX=$((INDEX+1))
done
