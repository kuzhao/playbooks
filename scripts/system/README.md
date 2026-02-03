### System scripts
Observing Linux internals purposefully.  
|Script|Synopsis|Usage|
|---|---|---|
|pid-tcptrace.sh|Collect TCP connect events per pid and packet dump, then separate the dump into session files per pid|bash pid-tcptrace.sh -t DURATION_SECS -p PID|