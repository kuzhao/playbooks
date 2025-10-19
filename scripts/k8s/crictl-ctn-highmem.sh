#!/bin/bash

################
#Dependency:
#  crictl,pstree
#  containerd service up and running
#Code logic:
# Output a list of all containers plus their pod names and pids
# Output top memory consuming PIDs
################

crictl ps -o json | jq -r '.containers[] | [.id, .labels."io.kubernetes.pod.name", .metadata.name] | @tsv' | while read -r container_id pod_name container_name; do pid=$(crictl inspect "$container_id" | jq -r '.info.pid'); pstree -pT $pid; echo "Container: $container_name, Pod: $pod_name, PID: $pid"; done
ps -eo pid,ppid,user,%mem,%cpu,rss,stat,start,time,comm --sort=-%mem | head -n 6 | awk 'NR>1 {print $1}' | while read pid; do echo "Memory-intensive Process PID: $pid";pstree -pTs "$pid";done
