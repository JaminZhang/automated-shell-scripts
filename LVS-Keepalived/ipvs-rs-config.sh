#!/bin/bash
# Usage: ipvs-rs-config
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

/etc/init.d/functions

VIP=(
		192.168.1.30
	)

case "$1" in
start)
		echo "Start LVS of RealServer IP."
		for ((i=0; i<`echo ${#VIP[*]}`; i++))
		do
			Interface="lo:`echo ${VIP[$i]} | awk -F . '{print $4}'`"
			/sbin/ifconfig $Interface ${VIP[$i]} broadcast ${VIP[$i]} netmask 255.255.255.255 up
			route add -host ${VIP[$i]} dev $Interface
		done
		echo "1" > /proc/sys/net/ipv4/conf/lo/arp_ignore
		echo "2" > /proc/sys/net/ipv4/conf/lo/arp_announce
		echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore
		echo "2" > /proc/sys/net/ipv4/conf/all/arp_announce
		;;
stop)
		echo "Stop LVS of RealServer IP."
		for ((i=0; i<`echo ${#VIP[*]}`; i++))
		do
			Interface="lo:`echo ${VIP[$i]} | awk -F . '{print $4}'`"
			route del -host ${VIP[$i]} dev $Interface
			/sbin/ifconfig $Interface ${VIP[$i]} broadcast ${VIP[$i]} netmask 255.255.255.255 down
		done
		echo "0" > /proc/sys/net/ipv4/conf/lo/arp_ignore		# When have multi VIPs, No-ARP should not apply. 
		echo "0" > /proc/sys/net/ipv4/conf/lo/arp_announce
		echo "0" > /proc/sys/net/ipv4/conf/all/arp_ignore
		echo "0" > /proc/sys/net/ipv4/conf/all/arp_announce
		;;
*)
		echo "Usage: $0 {start|stop}"
		exit 1
esac
