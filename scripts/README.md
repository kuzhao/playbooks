### Useful Scripts
This "scripts" folder contains many shell scripts that come in handy for specific purposes. See the specification for each of them in the table below.  
|Script|Synopsis|Usage|
|---|---|---|
|dump_aks_vmss.sh|List all AKS nodepool VMSS inside subscriptions passed via "subscriptions.txt"|Place target subids, one line for each, in the txt file then directly execute|
|pod-container-pid.sh|List container main PIDs of a pod with containerd as CRI|./pod-container-pid.sh PODNAME|
|start-aro.sh|Streamline ARO cluster provisioning with minumum VM sizes on both master and worker pools|./start-aro.sh|
|vm_runcmd.sh|Batch remove RunCommand VM extension over all instances in a VMSS|./vm_runcmd.sh -g VMSS_RG -v VMSS_NAME|
