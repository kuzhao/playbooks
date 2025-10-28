#!/bin/bash

################
#Dependency:
#  Install AzCli first
#Optional input:
#  RedHat OCP registry pull-secret file under name "pull-secret.txt"
#  should be placed under the current dir when this script is executed
################

az group create -l centralindia -g rg-centralindia
az network vnet create -n aro-vnet -g rg-centralindia --address-prefix 10.15.208.0/20 --subnet-name subnet1 --subnet-prefixes 10.15.209.0/24
az network vnet subnet update -n subnet1 --vnet-name aro-vnet -g rg-centralindia --service-endpoints Microsoft.ContainerRegistry
az network vnet subnet create -n aro-master --vnet-name aro-vnet -g rg-centralindia --address-prefixes 10.15.208.0/24 --service-endpoints Microsoft.ContainerRegistry --disable-private-link-service-network-policies true
# Follow https://docs.microsoft.com/en-us/azure/openshift/howto-add-update-pull-secret#prepare-your-pull-secret to get reg pull secrets from Red Hat OpenShift cluster manager portal
if [ -f pull-secret.txt ]; then
	az aro create --master-subnet aro-master -n aro-mock-38934 -g rg-centralindia --worker-subnet subnet1 --vnet aro-vnet --pull-secret @pull-secret.txt --worker-count 3 --master-vm-size Standard_D8as_v4 --worker-vm-size Standard_D4as_v4 --version 4.16.48
else 
	az aro create --master-subnet aro-master -n aro-mock-38934 -g rg-centralindia --worker-subnet subnet1 --vnet aro-vnet --worker-count 3 --master-vm-size Standard_D8as_v4 --worker-vm-size Standard_D4as_v4 --version 4.16.48
fi	
