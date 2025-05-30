#!/bin/bash

################
#Dependency:
#  Github repo contents of iovisor/bpftrace
#  - bpftrace release binary v0.18.0
#  - tcpconnect.bt bpftrace cfg
#Caution:
#  This script uses /tmp as working dir.
################

### Functions
getTraffic() {
	while IFS= read -r line; do
		local TMPLINE=$(echo $line | tr -s ' ')
		local SPORT=$(echo $TMPLINE | cut -d ' ' -f 5)
		local DPORT=$(echo $TMPLINE | cut -d ' ' -f 7)
		tcpdump -r /tmp/trace.pcap -w /tmp/session_port_pair_$SPORT-$DPORT.pcap tcp and port $SPORT and port $DPORT
	done <<< $(cat /tmp/tcp_sessions.txt | grep $TGTPID)
}

# Init var
DURATION=300

############ Start the execution ############
# Process Args -- 
# -t: Target duration of data capture
# -p: Target PID whose traffic is to be obtained 
while getopts p:t: flag;
do
    case "${flag}" in
        t) DURATION=${OPTARG};;
		p) TGTPID=${OPTARG};;
    esac
done

# Start capture
tcpdump -w /tmp/trace.pcap -s 72 -W 1 -G $DURATION &
PID_TCPDUMP=$!
# Start bpftrace for proc open port
wget -q https://github.com/iovisor/bpftrace/releases/download/v0.18.0/bpftrace -O bpftrace && chmod 755 bpftrace 
wget -q https://raw.githubusercontent.com/iovisor/bpftrace/master/tools/tcpconnect.bt -O tcpconnect.bt
bpftrace tcpconnect.bt > /tmp/tcp_sessions.txt &

# Wait for DURATION before wrapping up
sleep $DURATION
kill $!
kill $PID_TCPDUMP

getTraffic
