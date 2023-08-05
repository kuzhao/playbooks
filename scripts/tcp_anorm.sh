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

FlowSep() {
	mkdir pcap_sep
	for FLOW_IDX in $(seq 0 $CONV_NUM);
	do  # Fork one tshark process per FLOW after counting flow number
		# total tshark process count throttled to CPU core count
		tshark -nr results.pcap -Y "tcp.stream eq $FLOW_IDX" -q -w pcap_sep/tcp-s$FLOW_IDX.pcap > /dev/null 2>&1 &
		while true; do  # break the withholding while loop only if less tshark instances than cpu cores
			TSHARK_THREAD=$(ps -ef | grep $$ | grep tshark | wc -l)
			if [ $TSHARK_THREAD -lt $CPU_CORE ]; then
				break
			fi
			echo "Tshark thread count equals to cpu count. Wait for some to finish..."
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
FlowSep
Detect
