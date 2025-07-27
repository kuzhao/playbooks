#!/bin/bash
# A script to automatically start all VM/VMSS in given subs and resourcegroups.
############## Function definitions #############
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

validate_cluster() {
        GREP=$(az aks list -o table | grep $1) && return 0 || return 1
}


############ Start the execution ############
# Process Args --
# -s: SubscriptionId
# -c: Cluster Name
while getopts s:c: flag;
do
    case "${flag}" in
        s) SUBID=${OPTARG};;
        c) CLUSTER=${OPTARG};;
    esac
done
# Split subids and RGs into their arrays
IFS=', ' read -r -a SubidArray <<< $(echo $SUBID)
IFS=', ' read -r -a RgArray <<< $(echo $RG)
# az login
az login --identity
az account set -s $SUBID
if [[ $? -ne 0 ]]; then
        echo "Cannot switch to sub $SUBID"
        continue
fi
# Remove and add a new node pool
validate_cluster $CLUSTER
if [[ $? -ne 0 ]]; then
        echo "AKS cluster $CLUSTER does not exist."
else
        echo $GREP
        RG=$(echo $GREP | awk '{print $3}')
        echo "Remove the test node pool from cluster $CLUSTER"
        az aks nodepool delete --cluster-name $CLUSTER -n workertmp -g $RG
        if [[ $? -ne 0 ]]; then
                echo "Error when deleting the node pool."
	fi
        echo "Recreate the test node pool from cluster $CLUSTER"
        az aks nodepool add -c 0 --cluster-name $CLUSTER -n workertmp -g $RG
fi

