#!/bin/bash

input="subscriptions.txt"
if [[ ! -f $input ]]; then
	echo "Cannot find the subscription file $input."
	exit
fi

while IFS= read -r line; do
	SUBID=$(echo $line | xargs) &&	az account set -s $SUBID
	if [[ $? -ne 0 ]]; then
		echo "az account set errored out"
		continue
	fi
	echo "In subscription $SUBID, there are AKS clusters:"
	az aks list -o table
	# dump all AKS VMSS
	echo "VMSS:"
	while IFS= read -r line; do
		echo "Cluster RG $(echo $line | tr -d ',' | tr -d '\"')"
		az vmss list -g $(echo $line | tr -d ',' | tr -d '\"') -o table 
	done <<< $(az aks list --query [].nodeResourceGroup | tail -n +2 | head -n +2)

done < $input
