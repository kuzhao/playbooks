#!/bin/bash

################
#Dependency:
#  Install AzCli first
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
## Check az login
az_login

## Get VM and Nic info
RG=$(az vm list -o table | grep $1 | tr -s ' '| cut -d ' ' -f 2)
NIC_URI=$(az vm show -n $1 -g $RG --query 'networkProfile.networkInterfaces[0].id'| tail -n 1 |tr -d '"')
NIC_RG=$(cut -d '/' -f 5 <<< $NIC_URI);NIC_NAME=$(cut -d '/' -f 9 <<< $NIC_URI)
NIC_NSG_URI=$(az network nic show -n $NIC_NAME -g $NIC_RG --query networkSecurityGroup.id | tail -n 1)
if [ -z $NIC_NSG_URI ]; then
	echo 'VM NIC must have a NSG attached.'
	exit 1
fi
NIC_NSG_RG=$(cut -d '/' -f 5 <<< $NIC_NSG_URI);NIC_NSG_NAME=$(cut -d '/' -f 9 <<< $NIC_NSG_URI)

## Allow SSH/RDP
#let "NSG_RULE_COUNT = $(az network nsg show -n $NIC_NAME -g $NIC_RG | grep priority | wc -l) - 6"
az network nsg rule create -g $NIC_NSG_RG --nsg-name $NIC_NSG_NAME -n jit \
--priority 100 --source-address-prefixes Internet --destination-port-ranges 22 3389 \
--access Allow --protocol Tcp \
--description "Allow Internet to Web ASG on ports 80,8080."

if [ $? -ne 0 ]; then
	echo 'NSG rule op failed.'
	exit 1
fi

## Sleep for 4mins, wait for JIT to expire before removing the allow rule
echo 'Sleep for 4mins then remove the allow rule...'
sleep 240
az network nsg rule delete -g $NIC_NSG_RG --nsg-name $NIC_NSG_NAME -n jit
