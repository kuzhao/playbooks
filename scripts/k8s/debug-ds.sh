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

# Verify privileged pod can be deployed
kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep node-debugger | xargs kubectl delete pod
echo 'Use kubectl debug to test if you can create a privileged debug pod'
kubectl debug node/$(kubectl get node --no-headers -o custom-columns=':metadata.name' | head -n 1) --profile sysadmin --image $IMG -- sleep 120 || exit 1
sleep 10
kubectl get pod | grep node-debugger | grep Running \
  && echo 'Privileged pod create test passed' || fail 'Check the permission to create privilege pods'
kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep node-debugger | xargs kubectl delete pod

# Get nodeSelector param from argument
while getopts l: flag;
do
    case "${flag}" in
        l) SELECTOR=${OPTARG};;
    esac
done
# If no nodeSelector is provided, default to empty string
if [ -z "$SELECTOR" ]; then 
  SELECTOR="{}"
fi


commands=(
    "iotop -btoP -d 5"
)
# Clear existing debuggers
echo 'Clean up residue debuggers'
kubectl delete ds -l app=debugger-ds
# Apply debug daemonSets
# For each command, create and apply a pod YAML
INDEX=1
for cmd in "${commands[@]}"; do
  DS_NAME="debugger-ds-$INDEX"
  cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: $DS_NAME
  labels:
    app: debugger-ds
spec:
  selector:
    matchLabels:
      app: $DS_NAME
  template:
    metadata:
      labels:
        app: $DS_NAME
    spec:
      nodeSelector:
        $SELECTOR
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
      tolerations:
      - key: kubernetes.azure.com/scalesetpriority
        operator: Exists
        effect: NoSchedule
EOF
  echo "Applied ds $POD_NAME for command: $cmd"
  INDEX=$((INDEX+1))
done 
