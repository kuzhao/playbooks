#!/bin/bash
mkdir pcaps
cd pcaps
IFS=$'\n' read -rd ';' -a y
echo ''
for i in "${y[@]}";do
    wget $i
done
# Merge files
mergecap * -w ../dump.pcap
# Cleanup
cd .. && rm -rf pcaps
