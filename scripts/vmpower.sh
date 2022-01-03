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

validate() {
	IFEXIST_RG=$(az group exists -g $1)
	if [[ $IFEXIST_RG == 'false' ]]; then
		return 1
	else
		return 0
	fi
}

power_on() {
	echo "List all VM/VMSS and their states"
	echo "VM"
	az vm list -d -g $1 -o table
	echo "VMSS"
	az vmss list -g $1 -o table
	echo "Power them on"
	VMLIST=$(az vm list -g $1 -o table | sed 1,2d | awk '{print $1}')
	VMSSLIST=$(az vmss list -g $1 -o table | sed 1,2d | awk '{print $1}')
	for VM in $VMLIST;do
		az vm start -n $VM -g $1
	done
	for VMSS in $VMSSLIST;do
		az vmss start -n $VMSS -g $1
	done	
}

############ Start the execution ############
# Process Args -- 
# -s: subids separated by comma
# -g: RGs separated by comma
while getopts s:g: flag;
do
    case "${flag}" in
        s) SUBID=${OPTARG};;
        g) RG=${OPTARG};;
    esac
done
# Split subids and RGs into their arrays
IFS=', ' read -r -a SubidArray <<< $(echo $SUBID)
IFS=', ' read -r -a RgArray <<< $(echo $RG)
# az login
az_login

for i in ${SubidArray[@]};do
	az account set -s $i
	if [[ $? -ne 0 ]]; then
		echo "Cannot switch to sub $i"
		continue
	fi
	for j in ${RgArray[@]};do
		validate $j
		if [[ $? -ne 0 ]]; then
			echo "/subscriptions/$i/resourceGroups/$j does not exist."
			continue
		else
			echo "Powering on all VM/VMSS in /subscriptions/$i/resourceGroups/$j"
			power_on $j
		fi
	done
done