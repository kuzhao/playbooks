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
kubectl debug node/$(kubectl get node --no-headers -o custom-columns=':metadata.name' | head -n 1) --profile sysadmin --image $IMG -- sleep 120 || exit 1
sleep 10
kubectl get pod | grep node-debugger | grep Running \
  && echo 'Privileged pod validation passed' || fail 'Check the permission to create privilege pods'
kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep node-debugger | xargs kubectl delete pod

# Get nodeSelector param from argument
while getopts n:p: flag;
do
    case "${flag}" in
        n) NAMESPACE=${OPTARG};;
        p) POD=${OPTARG};;
    esac
done

if [ -z "$NAMESPACE" ] || [ -z "$POD" ]; then 
    fail "Namespace or Pod name not provided. Use -n for namespace and -p for pod name."
fi

# Get the node where the pod runs
NODE=$(kubectl get pods $POD -n $NAMESPACE --no-headers -o custom-columns=":spec.nodeName")
if [ -z "$NODE" ]; then
    fail "Cannot find the node for the given pod."
fi
# Get pod IP
POD_IP=$(kubectl get pods $POD -n $NAMESPACE --no-headers -o custom-columns=":status.podIP")
if [ -z "$POD_IP" ]; then
    fail "Cannot find the IP of the given pod."
fi

# Clear existing debuggers
kubectl delete pod -l app=pod-tcpdump
POD_NAME="$POD-tcpdump"
cmd="POD_VETH=\$(ip route | grep $POD_IP | awk '{print \$3}');tcpdump -i \$POD_VETH -s 120 -w /tmp/$POD_IP.pcap"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
  labels:
    debug-target: $POD
    app: pod-tcpdump
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
  nodeName: $NODE
EOF
echo "Applied pod $POD_NAME for command: $cmd"
