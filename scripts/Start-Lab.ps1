<#
Author: kuzhao@microsoft.com 
Usage: Start-Lab.ps1 [-index <labidx> -region <regioncode>]

# Change Log
06/20/2020: Initial CheckIn

# Description
This script, along with a bunch of ARM template files under its parent folder, offers a express way for a lab environment once a user az logined.
Default region if no "region" arg: eastus. Recommended: eastus, southcentralus, westus2, eastasia, australiaeast, northeurope, uksouth

# Prerequisites
The latest Azure CLI on Windows you can find
A fully cloned ARR "Script" repo

# Example
cd <ScriptRepoPath>\labtemplate\
.\Start-Lab.ps1

Index Description
----- -----------
0     Create a cluster with pods living in a vnet subnet. The cluster takes its identity from a managed identity
      resource.
1     Create a VM within a virtual gateway enabled vnet. You may then go ahead and configure a S2S VPN from anywhere!
2     Create 2 peered vnets. You will also find an Ubuntu in each vnet respectively. Goodie to have for back-to-back
      testing.
3     Spin up a win2019 DC and an Ubuntu 18.04 simultaneously in their own subnets within a vnet. Instantly empowers
      you with dual OS capability! Cost control optimized.

.\Start-Lab.ps1 1
...
    "provisioningState": "Succeeded",
    "template": null,
    "templateHash": "3048591787675885644",
    "templateLink": null,
    "timestamp": "2020-06-20T11:44:48.517139+00:00"
},
"resourceGroup": "rg-lab546048993",
"type": "Microsoft.Resources/deployments"
#>

Param (
    [int]$index=-10,
    [string]$region="eastus"
)

# Display Lab list if no item index is given
if ($index -eq -10) {
    Import-Csv "$PSScriptRoot\..\AzureRM\labManifest.csv" | Format-Table -Property Index,Description -Wrap
} else {
    $lab_manifest = Import-Csv "$PSScriptRoot\..\AzureRM\labManifest.csv"
    # Index input check
    if (($index -lt 0) -or (($lab_manifest | Measure-Object).Count -lt $index+1)) {
        Write-Output "Illegal lab item index."
        exit
    }
    # Active Azure account check
    try {
        az account show -o table
    } 
    catch { 
        "The az executable does not exist. Double check AzCli installation." 
        exit
    }
    Read-Host -Prompt 'Is the above the right sub? Ctrl-C to halt, or press ENTER to begin deployments.'

    # Execute corresponding deployments
    $labname = "lab"+ $(Get-Random)
    az group create -g "rg-$labname" -l $region
    az deployment group create --template-file $PSScriptRoot\..\AzureRM\$($lab_manifest[$index].templateFolder)\azuredeploy.json -g "rg-$labname"
}
