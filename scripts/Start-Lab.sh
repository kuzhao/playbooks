#!/bin/bash
# Author: kuzhao@microsoft.com 
# Usage: Start-Lab.ps1 [-index <labidx> -region <regioncode>]

# Description
# This script, along with a bunch of ARM template files under its parent folder, offers a express way for a lab environment once a user az logined.
# Default region if no "region" arg: eastus. Recommended: eastus, southcentralus, westus2, eastasia, australiaeast, northeurope, uksouth

# Prerequisites
# The latest Azure CLI on Windows you can find
# A fully cloned ARR "Script" repo

# Example
# cd <ScriptRepoPath>\labtemplate\
# .\Start-Lab.ps1

# Index Description
# ----- -----------
# 0     Create a cluster with pods living in a vnet subnet. The cluster takes its identity from a managed identity
#       resource.
# 1     Create a VM within a virtual gateway enabled vnet. You may then go ahead and configure a S2S VPN from anywhere!
# 2     Create 2 peered vnets. You will also find an Ubuntu in each vnet respectively. Goodie to have for back-to-back
#       testing.
# 3     Spin up a win2019 DC and an Ubuntu 18.04 simultaneously in their own subnets within a vnet. Instantly empowers
#       you with dual OS capability! Cost control optimized.

# .\Start-Lab.ps1 1
# ...
#     "provisioningState": "Succeeded",
#     "template": null,
#     "templateHash": "3048591787675885644",
#     "templateLink": null,
#     "timestamp": "2020-06-20T11:44:48.517139+00:00"
# },
# "resourceGroup": "rg-lab546048993",
# "type": "Microsoft.Resources/deployments"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ $# -eq 0 ]; then
      cat $SCRIPT_DIR/../AzureRM/labManifest.csv
else
      FOLDER=`cat $SCRIPT_DIR/../AzureRM/labManifest.csv | grep "$1," | awk '{print $2}'`
      if [ $FOLDER -eq '' ]; then
            echo "Illegal lab item index."
      else
            if [ $# -eq 2 ]; then
                  REGION=$2
            else
                  REGION="eastus"
            fi
            az account show
            if ![ $? -eq 0 ]; then
                  echo "Please az login first."
            else
                  LABNAME = "lab$RANDOM"
                  az group create -g "rg-$LABNAME" -l $REGION
                  az deployment group create --template-file $SCRIPT_DIR/../AzureRM/$FOLDER/azuredeploy.json -g "rg-$labname"
            fi
      fi
fi