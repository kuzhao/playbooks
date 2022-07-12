#!/bin/bash
# This script tests 3 facets of OS network connectivity:
# DNS (dig)
# TCP (nc + nping)
# HTTP (curl)
## Var declaration
FQDN_PROBE=('portal.azure.com' 'www.bing.com' 'google.com')
DNS_LIST=$(cat /etc/resolv.conf | grep nameserver | awk '{$1=""; print $0}'| sed 's/^ //g')
## Step 1: DNS lookup test over all nameservers
for SERVER in $DNS_LIST
do
echo "==============Testing DNS lookup against server: $SERVER==============="
for FQDN in ${FQDN_PROBE[@]}
do
dig $FQDN @$SERVER
done
echo "==============Done with testing against server: $SERVER================"
echo ""
done
for FQDN in ${FQDN_PROBE[@]}
do
## Step 2: TCP connectivity check
nc -v -w 2 -z $FQDN 443
nping -c 10 --tcp-connect --delay 300ms -p 443 $FQDN
## Step 3: HTTP Curl verbose probe
curl -w "dns_resolution: %{time_namelookup}, tcp_established: %{time_connect}, ssl_handshake_done: %{time_appconnect}, TTFB: %{time_starttransfer}\n" -m 3 -s $FQDN
done