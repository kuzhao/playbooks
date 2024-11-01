#!/bin/bash

function test_dummy_debug_pod() {
	kubectl debug node/$NODE --image ubuntu --profile sysadmin -- sleep 1 || {
		echo 'The current kubeuser cannot create privilege debug pod,exiting';exit 1
	}
}


######### Start Execution ##########
# Get target pod IP and node name, exit the execution when the pod doesn't exist
K_GET=$(kubectl get pod $1 -n $2 -o wide) || {
	echo 'Cannot find target pod in given namespace,exiting';exit 1
}
POD_IP=$(echo $K_GET | grep -oE '([0-9]+\.)+[0-9]+') && NODE=$(echo $K_GET | grep -oE 'aks-[[:alnum:]]+-[0-9]+-vmss[[:alnum:]]+')
if [ -z $POD_IP ] || [ -z $NODE ]; then
	echo 'Cannot get pod IP or the node it runs on'
	exit 2
fi

# Create debug pod on node
test_dummy_debug_pod
DEBUG_POD=$(kubectl debug node/$NODE --image blaze001/net-utils:v0.1 -- sleep 1000000 | grep -oP 'node-debugger-[\w-]+')
while true; do
	kubectl get pod $DEBUG_POD | grep 'Running' && break || sleep 5
done
POD_VETH=$(kubectl exec $DEBUG_POD -- ip route | grep $POD_IP | awk '{print $3}')
POD_NETNS=$(kubectl exec $DEBUG_POD -- chroot /host ip link show $POD_VETH | grep -oP 'cni-[\w-]+')
# Insert TCP SYN capture as ephemeral container
CTN_TCP_SYN=$(kubectl debug $DEBUG_POD --image blaze001/net-utils:v0.1 -- tcpdump -i $POD_VETH -s 80 -w test.pcap | grep -oP 'debugger-[\w]+')
# Create a new debug pod to dump existing sockets in target pod 
DEBUG_POD_SS=$(kubectl debug node/$NODE --image ubuntu --profile sysadmin -- chroot /host ip netns exec $POD_NETNS bash -c 'while true;do date;ss -np;sleep 5;echo;done > /tmp/ss_records.log' | grep -oP 'node-debugger-[\w-]+')

# Echoes
echo "Capture ongoing..."
echo "Primary debug pod: $DEBUG_POD"
echo "Ephem containers within primary debug pod:"
echo "    For TCP SYN capture: $CTN_TCP_SYN"
echo "ss cmd debug pod: $DEBUG_POD_SS"

echo "Copy out SYN capture by: kubectl cp -c $CTN_TCP_SYN $DEBUG_POD:/root/test.pcap ./tcp-syn.pcap"
echo "    And socket records by: kubectl cp $DEBUG_POD_SS:/host/tmp/ss_records.log ./ss_records.log"