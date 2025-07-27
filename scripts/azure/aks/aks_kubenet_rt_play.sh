#!/bin/bash
#
############## Functions #############
PreCheck() {
    # az-cli check
    az account show
    if [[ $? -ne 0 ]]; then
        echo "Please az login first."
        exit 1
    fi
}

ScaleUp() {
    # Scaling up
    echo "Scale agentpool by 2..."
    az aks nodepool scale --cluster-name $CLUSTER_NAME -g $RG -n nodepool1 \
        --node-count 5
    if [[ $? -ne 0 ]]; then
        echo "Scale up failed"
        exit 1
    fi
    ## Check if all nodes are online
    for i in {1..10};
    do
        kubectl get node | grep 'NotReady'
        if [[ $? -ne 0 ]]; then
            break
        fi
        echo "Continue polling until all nodes are ready.."
        sleep 30
    done
}

############ Start execution ############
# Var declaration
REGION="eastus"
RG="rg-$RANDOM"
CLUSTER_NAME="kubenet-vmas-$RANDOM"
 
PreCheck

# Start working
# Create a new kubenet cluster
echo 'Create temp resourceGroup..'
az group create -g $RG -l $REGION
echo 'Create cluster...'
az aks create -g $RG -n $CLUSTER_NAME --node-vm-size Standard_B2s --network-plugin kubenet --node-count 3
if [[ $? -ne 0 ]];then
    echo "Cluster creation failed."
    exit 1
fi

# Pre kubectl check
## test obtaining kubectl credential 
az aks get-credentials -n $CLUSTER_NAME -g $RG -a
if [[ $? -ne 0 ]]; then
    echo "Cannot obtain kubectl config"
    exit 1
fi
## Check if all nodes are online
for i in {1..10};
do
    kubectl get node | grep 'NotReady'
    if [[ $? -ne 0 ]]; then
        break
    fi
    echo "Continue polling until all nodes are ready.."
    sleep 30
    if [[ $i -eq 10 ]]; then
        echo "Not all nodes become ready after 300sec."
        exit 1
    fi
done

# Manuever starts
## remove the 2nd Ready node
TGT_NODE=$(kubectl get node | tail -n +3 | head -n 1 | tr -s ' ' | cut -d ' ' -f1)
if [[ $TGT_NODE =~ [a-zA-Z0-9-]+vmss ]];then
    VMSS=${BASH_REMATCH[0]};
else
    echo "$TGT_NODE, one of the nodes in kubectl get node, does not conform to the known node name pattern which contains the VMSS name."
    exit 1
fi
VMSS_IDX=${TGT_NODE: -1}
kubectl delete node $TGT_NODE
## Sleep before adding two fresh nodes
sleep 120

ScaleUp

## Reboot the deleted node VM before it re-registers
NODE_RG=$(az aks show -n $CLUSTER_NAME -g $RG --query nodeResourceGroup | tr -d '"')
az vmss restart -n $VMSS -g $NODE_RG --instance-ids $VMSS_IDX --no-wait
### Wait for the node to show up in kubectl
for i in {1..10};
do
    kubectl get node | grep $TGT_NODE
    if [[ $? -ne 0 ]]; then
        break
    fi
    echo "Continue polling until all nodes are ready.."
    sleep 30
    if [[ $i -eq 10 ]]; then
        echo "$TGT_NODE not showing after 300sec."
        exit 1
    fi
done
