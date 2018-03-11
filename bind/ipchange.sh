#!/bin/bash
# This script transfers the Nameserverdata from a dynamic IP host to the Nameserver in the Internet
# VARIABLES:
# INTERFACE: The interface connected to WAN
# REMOTEHOST: The remote host that gets the data
# REMOTEUSER: The user that logs into the remote host
# IPV6USER: The username for the IPV6 Tunnelbroker
# IPV6PASS: Password used for the IPV6 Tunnelbroker
# IPV6HOSTID: Hostid of this host for the Tunnelbroker
# IPV6REMOTEGATEWAY: IPV4 Adress of the remote Gateway
# IPV6NETWORK: The IPV6 Network routed through the tunnel
# LOGFILE: The logfile used here
INTERFACE=eth4
REMOTEHOST=host
REMOTEUSER=user
IPV6USER=user
IPV6PASS=password
IPV6HOSTID=hostid
IPV6REMOTEGATEWAY=gateway
IPV6NETWORK=network
LOGFILE=logfile

DATE=`date`
NEWIP=`ifconfig $INTERFACE |grep "inet Adr" | awk  '{ print $2 }' | awk -F : '{ print $2 }'`
OLDIP=`cat oldip`

cd /etc/bind
if [ $OLDIP == $NEWIP ]; then
	echo "$DATE Won't update" >> $LOGFILE
else
	echo "$DATE Will update with $NEWIP" >> $LOGFILE
	CURRENTDATE=`date -u +%Y%m%d`
	OLDDATE=`cat serialdate`
	OLDSERIAL=`cat serial`
	if [ $OLDDATE == $CURRENTDATE ]; then
		SERIAL=$(($OLDSERIAL + 1))
	else
		SERIAL="$CURRENTDATE"01
	fi
	echo $NEWIP > oldip
	echo $SERIAL > serial
	echo $CURRENTDATE > serialdate
	cp -a serial newserial
	cp -a oldip newip
	rsync -e ssh newserial REMOTEUSER@$REMOTEHOST:/etc/bind 
	rsync -e ssh newip REMOTEUSER@$REMOTEHOST:/etc/bind
	rm -f newip
	rm -f newserial
	ip link set he-ipv6 down
	ip tunnel del he-ipv6
	curl --user $IPV6USER:$IPV6PASS https://ipv4.tunnelbroker.net/nic/update?hostname=$IPV6HOSTID >> $LOGFILE
	ip tunnel add he-ipv6 mode sit remote $IPV6REMOTEGATEWAY local $NEWIP ttl 255
	ip link set he-ipv6 up
	ip addr add $IPV6NETWORK/64 dev he-ipv6
	ip route add ::/0 dev he-ipv6
	ip -f inet6 addr >> $LOGFILE
fi

