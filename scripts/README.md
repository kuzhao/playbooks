### Useful Scripts
This "scripts" folder contains many shell scripts that come in handy for specific purposes. See the specification for each of them in the table below.  
|Script|Synopsis|Usage|
|---|---|---|
|custom_img.sh|A custom Raspbian image builder |Chroot to [relative]fs/, install packages and change files, quit and rsync to empty img mountpoints|
|dump_aks_vmss.sh|List all AKS nodepool VMSS inside subscriptions passed via "subscriptions.txt"|Place target subids, one line for each, in the txt file then directly execute|
|jit-rdp-ssh.sh|Temporarily add administrative access of ssh and rdp to a given VM name|./jit-rdp-ssh.sh VMNAME|
|pod-container-pid.sh|List container main PIDs of a pod with containerd as CRI|./pod-container-pid.sh PODNAME|
|random-files.sh|Spawn n dummy files of random sizes under names from word dictionary|./random-files.sh NUM|
|renew_runcmd.sh|Manually refresh runCommand VM extension on the given VMSS|./renew_runcmd.sh -g RG -v VMSS|
|start-aro.sh|Streamline ARO cluster provisioning with minumum VM sizes on both master and worker pools|./start-aro.sh -i CLIENT_ID -s CLIENT_SECRET|
|start-mastodon.sh|Prepare and populate necessary cfg files before starting a mastodon server|./start-mastodon.sh|
|update-imglist.sh|Pull major Linux distribution versions on Azure into TSVs|./update-imglist.sh|
|vmpower.sh|Batch power on all VMs in a resource group|./vmpower.sh -s SUBSCRIPTION_ID -g RG_NAME|
