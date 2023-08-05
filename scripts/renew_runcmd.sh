#!/bin/bash

################
#Dependency:
#  Install AzCli first
################

# Process Args
while getopts g:v: flag;
do
    case "${flag}" in
        g) RG_NAME=${OPTARG};;
        v) VMSS=${OPTARG};;
    esac
done

echo "Target VMSS: ${VMSS}"
echo "in resource group ${RG_NAME}"
echo "============================="

# Renew runCommand on instances when necessary
for i in $(az vmss list-instances -g $RG_NAME --name $VMSS -o tsv | awk '{print $4}' | awk -F '/' '{print $NF}');do
        echo "On instance $i"
        az vmss get-instance-view -g ${RG_NAME} --name ${VMSS} --instance-id $i --query vmAgent.extensionHandlers | grep RunCommandLinux
        if [[ $? -eq 0 ]]; then
                echo "Instance $i currently has runCommand extension. Refreshing the extension."
                az vmss run-command invoke -g ${RG_NAME} --name ${VMSS} --command-id RemoveRunCommandLinuxExtension --instance-id $i
        else
                echo "Instance $i does not have runCommand extension installed. No need to refresh."
        fi
done
