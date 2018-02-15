#!/bin/bash
# define user parameters
export IPT="/sbin/iptables"
export bdir="~/bak/"

## interface cards
## base subnets

## add subnet (.0) information
export exsub="192.168.0.0/24"
export insub="192.168.10.0/24"
## define internal and external gateways
export infw="192.168.10.2"
export inpc="192.168.10.1"

#export expc=$(ifconfig | sed -n '2 p' | awk '{print $2}' )
export exfw="192.168.0.1"

## internet
export exif="eno1"
#export exip="192.168.0.0/24"

## internal
export inif="enp3s2"
#export inip="192.168.1.0/24"
#export firewall_ip="192.168.1.1"
	#ports
	export tcp_="22 80 443"
	export udp_="53 67 68"
	export icmp_="0 8"
	export drop_="23" #user specific
	export tcp_deny="23 111 137 138 139 515 32768 32771 32775"
	export udp_deny="23 111 137 138 139 515 32768 32771 32775"
	export icmp_deny="200"