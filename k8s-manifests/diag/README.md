### Useful Debug YAMLs
This folder hosts K8s YAMLs which help with diagnostic output or config tweak, usually in the form of daemonSet. 
Detailed deploy/daemonSet properties as well as container cmds may need review and modification before application to your env.

|YAML|Synopsis|When to use|
|---|---|---|
|disable-daily-upgrade|A DaemonSet which turns off Ubuntu daily security patching|Node tuning|
|dump-conntrack|A DaemonSet that Dumps to stdout the current conntrack table of node|Service check|
|dump-mem-proc|A DaemonSet printing to stdout topN cpu consuming processes|Process monitoring|
|dump-pstree|A DaemonSet printing to stdout the full pstree on node|Process monitoring|
|dump-iotop|A DaemonSet dumping to Azure File PVC topN disk IO consuming processes on node|IO monitoring|
|dump-pthread|[High CPU consuming]A DaemonSet dumping to Azure File PVC all child processes of each pod as well as topN thread consuming processes on node|Process monitoring|
|enable-kdump|Install kdump toolkit and enable kdump on node (Need subsequent node restart)|Node tuning|
|netcat-probe|Start a pod that probes given IP with netcat|Traffic check|
|set-node-pidmax|Customize through a daemonSet OS max process/thread count through /proc/sys/kernel/pid_max|Node tuning|
|tcpdump-node-affi|A DaemonSet which dumps live traffic to attached Azure Fileshare PVC with nodeSelector|Traffic capture|
|tcpdump-pod-affi|A Deploy dumping live traffic to attached Azure Fileshare PVC, can set replica # and podAffinity|Traffic capture|
