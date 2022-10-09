#!/bin/bash

echo 'Pulling SuSE image list...'
az vm image list --location eastus --publisher SUSE --output tsv --all > suse_img.tsv
echo 'done'
echo 'Pulling RH image list...'
az vm image list --location eastus --publisher RedHat --output tsv --all > rh_img.tsv
echo 'done'
echo 'Pulling Microsoft image list...'
az vm image list --location eastus --publisher Microsoft --output tsv --all > win_img.tsv
echo 'done'
echo 'Pulling Canonical image list...'
az vm image list --location eastus --publisher Canonical --output tsv --all > canonical_img.tsv
echo 'done'
