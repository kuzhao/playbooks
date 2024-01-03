#!/bin/bash
################
#Dependency:
#  tshark
#Input:
#  Place all pcap files to be processed under current dir
#  before exec this script
#Output:
#  - "pcap_sep" child folder which contains subset pcaps of all TCP flows
#  - "pcap_anorm" child folder which contains abnormal TCP flow pcaps
#Caution
#  The execution costs ~90% of CPU cycles;
#  Ensure extra storage space under current dir equaling to sum of input pcap files
################

# Var
PCAP_ROOT_DIR=$(pwd)
CPU_CORE=$(grep -c ^processor /proc/cpuinfo)

# Functions
TcpConvCount() {  # This function counts the number of tcp flows, result is the actual count - 1 
	tshark -nr results.pcap -q -z conv,tcp | tee flow_list.txt
	((CONV_NUM=$(cat flow_list.txt | wc -l) - 7))
}

DnsSub() {
	tshark -r result.pcap 'dns' | grep -i -v 'no such name'| grep 'query response'|grep -v 'AAAA'| tr -s ' '| awk -F ' ' '{print $13 " " $NF}' | sort -u > dns.txt
	while IFS= read -r line; do
		IP1=$(echo $line|tr -s ' '|cut -d ' ' -f1|cut -d ':' -f1)
		PORT1=$(echo $line|tr -s ' '|cut -d ' ' -f1|cut -d ':' -f2)
		IP2=$(echo $line|tr -s ' '|cut -d ' ' -f3|cut -d ':' -f1)
		PORT2=$(echo $line|tr -s ' '|cut -d ' ' -f3|cut -d ':' -f2)
		TMP_GREP=$(grep $IP1 dns.txt) && HOST1=$(echo $TMP_GREP|cut -d ' ' -f1)||HOST1=$IP1
		TMP_GREP=$(grep $IP2 dns.txt) && HOST2=$(echo $TMP_GREP|cut -d ' ' -f1)||HOST2=$IP2
		echo "$HOST1:$PORT1 <-> $HOST2:$PORT2" >> flow_dns.txt
	done <<< $(cat flow_list.txt | tail -n +6 | head -n -1)
}

FlowSep() {
	mkdir pcap_sep
	for FLOW_IDX in $(seq 0 $CONV_NUM);
	do  # Fork one tshark process per FLOW after counting flow number
		# tshark process count throttled to CPU core count all the time
		echo "Splitting flow No.$FLOW_IDX"
		tshark -nr results.pcap -Y "tcp.stream eq $FLOW_IDX" -q -w pcap_sep/tcp-s$FLOW_IDX.pcap > /dev/null 2>&1 &
		while true; do  # break the withholding while loop only if less tshark instances than cpu cores
			TSHARK_THREAD=$(ps -ef | grep $$ | grep tshark | wc -l)
			if [ $TSHARK_THREAD -lt $CPU_CORE ]; then
				break
			fi
			echo "Tshark thread count equals to cpu count. Wait for some to finish before a new fork..."
			sleep 5
		done
	done
} 

Detect() {
	mkdir pcap_anorm
	for i in $(ls pcap_sep);
	do  # copy the currently examined flow to anormaly folder if: there is reset; there is no fin
		if [ $(tshark -nr pcap_sep/$i -Y 'tcp.flags.reset==1' 2> /dev/null | wc -l) -ne 0 ]; then
			if [ $(tshark -nr pcap_sep/$i -Y 'tcp.flags.fin==1' 2> /dev/null | wc -l) -eq 0 ]; then
				cp pcap_sep/$i pcap_anorm
			fi
		fi 
	done

}

############ Start Execution ############
mergecap *.pcap* -w results.pcap
TcpConvCount
DnsSub
FlowSep
Detect
