#!/bin/bash
# define user parameters
export IPT="/sbin/iptables"
export bdir="~/bak/"

## interface cards
## base subnets
export _AB="192.168"

## add subnet (.0) information
export exsub="$_AB.0"
export insub="$_AB.10"
## define internal and external gateways
export exgw="$exsub.1"
export ingw="$insub.1"

## workstation
export _ws="14"

## client setup
export client_ip="$insub.15"

## external and internal IP address
export exip="$exsub.$_ws"
export inip="$insub.$_ws"

## internet
export exif="eno1"
#export exip="192.168.0.0/24"

## internal
export inif="enp3s2"
#export inip="192.168.1.0/24"
#export firewall_ip="192.168.1.1"
	#ports
	export tcp_="15,21,22,53,80,443"
	export udp_="22"
	export icmp_="0,8"
	export drop_="23"
