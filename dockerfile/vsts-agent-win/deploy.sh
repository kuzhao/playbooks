#!/bin/bash
## Prerequisite
## - The ACR must be attached to the AKS cluster in use beforehand.

## Variables
TOKEN_TBD=''
ADO_ORG_URL='https://dev.azure.com/ORG'
POOLNAME='mypool-aks'
ACR_NAME=''

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

## Execution starts
### Start building agent image
az_login
! az acr build -r $ACR_NAME -t vsts-agent-win:v1 . --platform windows && echo 'ACR build failed.' && exit 1

sed -i "s/TOKEN_TBD/$TOKEN_TBD/" deployment.yaml
sed -i "s/ADO_ORG_URL/$ADO_ORG_URL/" deployment.yaml
sed -i "s/POOLNAME/$POOLNAME/" deployment.yaml
sed -i "s/ACRNAME/$ACR_NAME.azurecr.io/" deployment.yaml

## Deploy ADO agent
kubectl apply -f deployment.yaml
