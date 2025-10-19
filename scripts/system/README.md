### System scripts
Observing Linux internals purposefully.  
|Script|Synopsis|Usage|
|---|---|---|
|pid-tcptrace.sh|Collect both TCP socket history and packet dump for given pid, then separate the dump into dump files per session|bash pid-tcptrace.sh -t DURATION_SECS -p PID|