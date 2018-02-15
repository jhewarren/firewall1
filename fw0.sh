#!/bin/bash

source config.sh >/dev/null
fw_public_ip=$(ifconfig eno1 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

# backup existing network settings
function netbackup(){
	mkdir ~/bak
	iptables-save > ~/bak/iptables.bak
	cp /etc/sysconfig/network-scripts/ifcfg* ~/bak/
	route > ~/bak/route.bak
}

#Set up nat and route settings
function nat_setup(){
    #setup network card setting
	ifconfig $inif up
	ifconfig $inif $infw netmask 255.255.255.0

    echo "1" > /proc/sys/net/ipv4/ip_forward
	echo "nameserver 8.8.8.8" > /etc/resolv.config

	route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.0.100
	route add -net $insub gw $infw

	$IPT -t nat -A POSTROUTING -j SNAT -s $insub -o $exif -m state --state NEW,ESTABLISHED --to-source $fw_public_ip
	$IPT -t nat -A PREROUTING -p tcp -i $exif -m state --state NEW,ESTABLISHED -j DNAT --to-destination $inpc
}

function restore(){
	ip link set $inif down
	ip link set $exif up
	iptables-restore < ~/bak/iptables.bak
}

#Delete all privious chains and rules
function reset(){
	$IPT -F
	$IPT -X
}

#Set all chains to DROP as default so we can set up a whitelist
function default(){
	$IPT --policy INPUT DROP
	$IPT --policy FORWARD DROP
	$IPT --policy OUTPUT DROP

	$IPT -A udp_chain -j ACCEPT

	$IPT -A PREROUTING -t mangle -p tcp --dport 20 -j TOS --set-tos Maximize-Throughput
	$IPT -A PREROUTING -t mangle -p tcp --sport 20 -j TOS --set-tos Maximize-Throughput

	$IPT -A PREROUTING -t mangle -p tcp --dport 21 -j TOS --set-tos Minimize-Delay
	$IPT -A PREROUTING -t mangle -p tcp --sport 21 -j TOS --set-tos Minimize-Delay

	$IPT -A PREROUTING -t mangle -p tcp --dport 22 -j TOS --set-tos Minimize-Delay
	$IPT -A PREROUTING -t mangle -p tcp --sport 22 -j TOS --set-tos Minimize-Delay
}

function drop(){
	#Do not accept any packets with a source address from the outside matching your internal network.
	$IPT -A FORWARD -i $exif -s $insub -j no_chain

	#DROP connections that are coming the “wrong” way (i.e., inbound SYN packets to high ports).
	$IPT -A FORWARD -p tcp -i $exif -o $inif --dport 1024: --tcp-flag SYN SYN -j no_chain

	#DROP all TCP packets with the SYN and FIN bit set.
	$IPT -A FORWARD -p tcp --tcp-flag SYN,FIN SYN,FIN -j no_chain

	#Block all external traffic directed to TCP ports 32768 – 32775, 137 – 139
	$IPT -A FORWARD -o $exif -i $inif -p tcp --dport 32755:32768 -j no_chain
	$IPT -A FORWARD -o $exif -i $inif -p tcp --dport 137:139 -j no_chain
	#Block all external traffic directed to UDP ports 32768 – 32775, 137 – 139
	$IPT -A FORWARD -o $exif -i $inif -p udp --dport 32755:32768 -j no_chain
	$IPT -A FORWARD -o $exif -i $inif -p udp --dport 137:139 -j no_chain
	#Block all external traffic directed to TCP ports 111 and 515.
	$IPT -A FORWARD -o $exif -i $inif -p tcp -m multiport --dport 111,515 -j no_chain

	#Drop fragments from new connections
	$IPT -A FORWARD -p tcp -i $exif -o $inif -m state --state NEW -f -j no_chain
	$IPT -A FORWARD -p tcp -o $exif -i $inif -m state --state NEW -f -j no_chain
	$IPT -A FORWARD -p udp -i $exif -o $inif -m state --state NEW -f -j no_chain
	$IPT -A FORWARD -p udp -o $exif -i $inif -m state --state NEW -f -j no_chain

	#User specified
	for i in $drop_; do
		$IPT -A FORWARD -p tcp --dport $i -j no_chain
		$IPT -A FORWARD -p tcp --sport $i -j no_chain
		$IPT -A FORWARD -p udp --dport $i -j no_chain
		$IPT -A FORWARD -p udp --sport $i -j no_chain
	done

	$IPT -A no_chain -m limit --limit 10/min -j LOG --log-prefix "Firewall-dropped: " --log-level 4
	$IPT -A no_chain -j DROP
}

#Create all user chains
function chain(){
	$IPT -N tcp_chain
	$IPT -N udp_chain
	$IPT -N icmp_chain
	$IPT -N no_chain
}

function tcp(){
	echo "TCP ports"
	for i in $tcp_; do
		$IPT -A FORWARD -p tcp -m tcp --dport $i -m state --state NEW,ESTABLISHED -j tcp_chain
		$IPT -A FORWARD -p tcp -m tcp --sport $i -m state --state NEW,ESTABLISHED -j tcp_chain
	done
	$IPT -A tcp_chain -j ACCEPT
	echo "tcp done"
	echo "---------"
}

function udp(){
	echo "udp types"
	for i in $udp_; do
		$IPT -A FORWARD -p udp --dport $i -m state --state NEW,ESTABLISHED -j udp_chain
		$IPT -A FORWARD -p udp --sport $i -m state --state NEW,ESTABLISHED -j udp_chain
	done
	$IPT -A FORWARD -j ACCEPT
	echo "udp done"
	echo "---------"
}

function icmp(){
	echo "icmp types"
	for i in $icmp_; do
		$IPT -A FORWARD -p icmp -m icmp --icmp-type $i -j icmp_chain
	done
	$IPT -A icmp_chain -j ACCEPT
	echo "icmp done"
	echo "---------"
}

nat_setup
reset
chain
default
drop
tcp
udp
icmp
