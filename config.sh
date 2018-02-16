#!/bin/bash
# define user parameters
export IPT="/sbin/iptables"
export bdir="~/bak/"

# base subnets
export exsub="192.168.0.0/24"
export insub="192.168.10.0/24"
# firewall internal ip
export infw="192.168.10.1"
# client internal ip
export inpc="192.168.10.2"

#export expc=$(ifconfig | sed -n '2 p' | awk '{print $2}' )
export exfw="192.168.0.1"

## internet interface
export exif="eno1"

## internal interface
export inif="enp3s2"
	#ports
	export tcp_="20 21 22 53 80 443"
	export udp_="20 21 22 53"
	export icmp_="0 3 8"
	export drop_="23" #user specific
	export tcp_deny="23 111 137 138 139 515 32768 32775"
	export udp_deny="23 111 137 138 139 515 32768 32775"
	export icmp_deny="200"
