### Azure scripts
Azure specific automations that print and operate.  
|Script|Synopsis|Usage|
|---|---|---|
|jit-rdp-ssh.sh|Temporarily add administrative access of ssh and rdp to given VM name|bash jit-rdp-ssh.sh VMNAME|
|renew_runcmd.sh|Manually refresh runCommand VM extension on the given VMSS|bash renew_runcmd.sh -g RG_NAME -v VMSS_NAME|
|start-aro.sh|Streamline ARO cluster provisioning with minumum VM sizes on both master and worker pools|bash start-aro.sh -i CLIENT_ID -s CLIENT_SECRET|
|vm-jit-port.sh|Grant timed access to given port on VM where it runs |bash vm-jit-port.sh|
|vmpower.sh|Power on all VMs in resource groups|bash vmpower.sh -s [SUB_ID,..] -g [RG_NAME,..]|
