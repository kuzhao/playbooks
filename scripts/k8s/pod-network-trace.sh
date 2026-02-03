#!/bin/bash

################
#To be run on k8s nodes
#Dependency:
#  tcpdump
#Code logic:
# Obtain target pod's veth intf and network namespace
# Do tcpdump on the veth and other network diagnostics in its netns
################

POD_VETH=$(ip route | grep $1 | awk '{print $3}')
POD_NETNS=$(chroot /host ip link show $POD_VETH | grep -oP 'cni-[\w-]+')
# Insert TCP SYN capture as ephemeral container
chroot /host tcpdump -i $POD_VETH -s 80 -w /tmp/test.pcap &
# Create a new debug pod to dump existing sockets in target pod 
chroot /host ip netns exec $POD_NETNS bash -c 'while true;do date;ss -np;sleep 5;echo;done > /tmp/ss_records.log' &
