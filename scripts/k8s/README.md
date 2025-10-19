### K8s debug scripts
They dump wanted debug data on a target node.  
|Script|Synopsis|Usage|
|---|---|---|
|crictl-ctn-highmem.sh|List all containers with their PIDs, and top x memory using PIDs in the OS|crictl-ctn-highmem.sh|
|pod-container-pid.sh|List out all PIDs under given pod with containerd as container runtime|bash pod-container-pid.sh PODNAME|
|pod-network-trace.sh|Collect both network packet dump and TCP/UDP sessions inside given pod|bash pod-network-trace.sh PODNAME NAMESPACE|
