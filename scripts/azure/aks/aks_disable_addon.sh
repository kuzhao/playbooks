#!/bin/bash
############## Function definitions #############
az_login() {
    az account show -o table
    if [ $? -ne 0 ]; then
        echo "Please az login first."
        exit 1
    fi
}
############ Start the execution ############
# az login
az_login

for i in $(az aks list -o table | tail -n +3 | cut -d ' ' -f 1);do
    echo "Processing cluster $i..."
    CLUSTER_RG=$(az aks list -o table | grep $i | tr -s ' ' | cut -d ' ' -f 3)
    for ext in $(az aks addon list -n $i -g $CLUSTER_RG -o table | grep -i true | cut -d ' ' -f 1);do
        echo "  Stopping addon $ext...";echo
        az aks addon disable -a $ext -n $i -g $CLUSTER_RG -o none
    done
done
