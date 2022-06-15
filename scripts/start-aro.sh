#!/bin/bash
az group create -l centralindia -g rg-centralindia
az network vnet create -n aro-vnet -g rg-centralindia --subnet-name subnet1 --subnet-prefixes 10.0.0.0/24
az network vnet subnet update -n subnet1 --vnet-name aro-vnet -g rg-centralindia --service-endpoints Microsoft.ContainerRegistry
az network vnet subnet create -n aro-master --vnet-name aro-vnet -g rg-centralindia --address-prefixes 10.0.255.0/24 --service-endpoints Microsoft.ContainerRegistry --disable-private-link-service-network-policies true
# Follow https://docs.microsoft.com/en-us/azure/openshift/howto-add-update-pull-secret#prepare-your-pull-secret to get reg pull secrets from Red Hat OpenShift cluster manager portal
if [ -f pull-secret.txt ]; then
	az aro create --master-subnet aro-master -n aro-mock-38934 -g rg-centralindia --worker-subnet subnet1 --vnet aro-vnet --pull-secret @pull-secret.txt --worker-count 3 --master-vm-size Standard_D8s_v3 --worker-vm-size Standard_D4as_v4
else 
	az aro create --master-subnet aro-master -n aro-mock-38934 -g rg-centralindia --worker-subnet subnet1 --vnet aro-vnet --worker-count 3 --master-vm-size Standard_D8s_v3 --worker-vm-size Standard_D4as_v4
fi	