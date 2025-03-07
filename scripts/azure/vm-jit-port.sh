#!/bin/bash

# Grant "JIT" port open in VM NSG
# This script requires the VM has managed identity assigned under Network Contributor role
################
#Dependency:
#  AzCli
#  (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-1-install-with-one-command)
################

############ Start Execution ############
az login -i
# Obtain NIC and NSG info of the current VM
RG=$(az vm list -o table | grep xternal | tr -s ' '| cut -d ' ' -f 2)
NIC_URI=$(az vm show -n Linux-External-Access -g $RG --query 'networkProfile.networkInterfaces[0].id'| tail -n 1 |tr -d '"')
NIC_RG=$(cut -d '/' -f 5 <<< $NIC_URI)
NIC_NAME=$(cut -d '/' -f 9 <<< $NIC_URI)
NIC_NSG_URI=$(az network nic show -n $NIC_NAME -g $NIC_RG --query networkSecurityGroup.id | tail -n 1)
if [ -z $NIC_NSG_URI ]; then
        echo 'VM NIC must have a NSG attached.'
        exit 1
fi
NIC_NSG_RG=$(cut -d '/' -f 5 <<< $NIC_NSG_URI)
NIC_NSG_NAME=$(cut -d '/' -f 9 <<< $NIC_NSG_URI | cut -d '"' -f 1)
echo $NIC_NSG_RG+++$NIC_NSG_NAME+++$NIC_NSG_URI
# Grant port access through AllowRule
az network nsg rule create -g $NIC_NSG_RG --nsg-name $NIC_NSG_NAME -n jit \
--priority 100 --source-address-prefixes Internet --destination-port-ranges 80 \
--access Allow --protocol Tcp \
--description "Allow Internet access on 80"

# Close temp access
az network nsg rule delete -g $NIC_NSG_RG --nsg-name $NIC_NSG_NAME -n jit
