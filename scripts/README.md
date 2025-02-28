### Useful Scripts
This "scripts" folder contains many shell scripts that come in handy for specific purposes. See the specification for each of them in the table below.  
|Script|Synopsis|Usage|
|---|---|---|
|dump_aks_vmss.sh|List all AKS nodepool VMSS inside subscriptions passed in from input file|bash dump_aks_vmss.sh|
|jit-rdp-ssh.sh|Temporarily add administrative access of ssh and rdp to given VM name|bash jit-rdp-ssh.sh VMNAME|
|klog_showfunc.sh|Mark Go package and function names for each line of given log file produced by klog|bash klog_showfunc.sh -l LOGFILE_PATH -b CODEBASE_PATH|
|pid-tcptrace.sh|Collect both TCP socket history and packet dump for given pid, then separate the dump into dump files per session|bash pid-tcptrace.sh -t DURATION_SECS -p PID|
|pod-container-pid.sh|List out all PIDs under given pod with containerd as container runtime|bash pod-container-pid.sh PODNAME|
|pod-network-trace.sh|Collect both network packet dump and TCP/UDP sessions inside given pod|bash pod-network-trace.sh PODNAME NAMESPACE|
|random-files.sh|Spawn n dummy files of random sizes under names from word dictionary|bash random-files.sh FILE_NUM|
|renew_runcmd.sh|Manually refresh runCommand VM extension on the given VMSS|bash renew_runcmd.sh -g RG_NAME -v VMSS_NAME|
|start-aro.sh|Streamline ARO cluster provisioning with minumum VM sizes on both master and worker pools|bash start-aro.sh -i CLIENT_ID -s CLIENT_SECRET|
|tcp_anorm.sh|Check if unusual TCP RST or FIN among given pcaps|bash tcp_anorm.sh|
|vm-jit-port.sh|Grant timed access to given port on VM where it runs |bash vm-jit-port.sh|
|vmpower.sh|Power on all VMs in resource groups|bash vmpower.sh -s [SUB_ID,..] -g [RG_NAME,..]|
