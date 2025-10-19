### Useful Scripts
This "scripts" folder contains many shell scripts that come in handy for specific system purposes. See the specification for each of them in the table below.  
It also contains several sub folders with further README in each.  
|Script|Synopsis|Usage|
|---|---|---|
|klog_showfunc.sh|Mark Go package and function names for each line of given log file produced by klog|bash klog_showfunc.sh -l LOGFILE_PATH -b CODEBASE_PATH|
|system/pid-tcptrace.sh|Collect both TCP socket history and packet dump for given pid, then separate the dump into dump files per session|bash pid-tcptrace.sh -t DURATION_SECS -p PID|
|k8s/pod-container-pid.sh|List out all PIDs under given pod with containerd as container runtime|bash pod-container-pid.sh PODNAME|
|k8s/pod-network-trace.sh|Collect both network packet dump and TCP/UDP sessions inside given pod|bash pod-network-trace.sh PODNAME NAMESPACE|
|random-files.sh|Spawn n dummy files of random sizes under names from word dictionary|bash random-files.sh FILE_NUM|
|tcp_anorm.sh|Check if unusual TCP RST or FIN among given pcaps|bash tcp_anorm.sh|
