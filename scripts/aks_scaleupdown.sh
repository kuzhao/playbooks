#!/bin/bash
#
############## Function definitions #############
PreCheck() {
    # az-cli check
    az aks show -n $CLUSTER -g $RG -o table
    if [[ $? -ne 0 ]]; then
        echo "Cluster not found."
        exit 1
    fi

    # test obtaining kubectl credential 
    az aks get-credentials -n $CLUSTER -g $RG -a
    if [[ $? -ne 0 ]]; then
        echo "Cannot obtain kubectl config"
        exit 1
    fi
    # Check if all nodes are online
    kubectl get node | grep 'NotReady'
    if [[ $? -eq 0 ]]; then
        echo "One or more nodes are not ready. Make all your nodes ready."
        exit 1
    fi
}

ScaleUpDown() {
    # Scaling up
    echo "Scale testspotpool to $SCALE..."
    az aks nodepool scale --cluster-name $CLUSTER -g $RG -n testspotpool \
        --node-count $SCALE
    if [[ $? -ne 0 ]]; then
        echo "Scale up failed. Scaling back to 0 node."
        az aks nodepool scale --cluster-name $CLUSTER -g $RG -n testspotpool \
        --node-count 0
        if [[ $? -ne 0 ]]; then
            echo "Scale back failed. Removing the test node pool and quit."
            az aks nodepool delete --cluster-name $CLUSTER -g $RG -n testspotpool
            exit 1
        fi
    fi
    # Wait for 10min and check if pods pending
    echo 'Sleep for 10mins...'
    sleep 600
    kubectl get pod -o wide | grep -v NAME | grep -v Running
    if [[ $? -eq 0 ]]; then
        echo "Reproduced."
        exit 0
    fi
    # No reproduction. Scale down.
    echo "Not reproduced. Scale back to 0..."
    az aks nodepool scale --cluster-name $CLUSTER -g $RG -n testspotpool \
        --node-count 0
}

############ Start the execution ############
# Process Args
while getopts n:g:c: flag;
do
    case "${flag}" in
        n) CLUSTER=${OPTARG};;
        g) RG=${OPTARG};;
        c) SCALE=${OPTARG};;
    esac
done
echo "Target cluster: ${CLUSTER}"
echo "in resource group ${RG}"
 
PreCheck

# Start working
# Create a test nodepool
echo 'Create test nodepool testspotpool...'
az aks nodepool add --cluster-name $CLUSTER -g $RG -n testspotpool \
    --node-osdisk-type ephemeral --priority Spot --node-vm-size Standard_F2s_v2 --node-count 0
if [[ $? -ne 0 ]];then
    echo "Test nodepool creation failed."
    exit 1
fi
# Loop for repro
while true; do
    ScaleUpDown
    sleep 180
done
