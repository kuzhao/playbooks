#!/bin/bash

################
#Dependency:
#  Install AzCli first
#Input:
#  A txt file of list that contains subscriptions to query. Example:
#$ cat subscriptions.txt
#64793281-f041-459a-8d19-e181d0f8090a
#1f5afbfb-a346-4ef8-b65d-ce9b80d699ff
#46194214-04a7-492e-98b7-e118ae9a623b
#f9e798aa-093e-46a8-b2c5-29daad408516
#99e8ca95-7631-405f-82a2-0ef80eda5de2
################

### Functions
az_login() {
	az account show -o table
	if ! [ $? -eq 0 ]; then
	    echo "Please az login first."
		az login --use-device-code	
		if [[ $? -ne 0 ]]; then
			echo "az login failed. Quitting"
			exit 1
		fi
	else
	    # Prompt user to confirm if the correct sub is selected
	    echo "Is the above correct subscription? Press Ctrl-C to cancel" && read DUMMY_INPUT
	fi
}

############ Start Execution ############
input="subscriptions.txt"
if [[ ! -f $input ]]; then
	echo "Cannot find the subscription file $input."
	exit
fi
## Check az login
az_login

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
