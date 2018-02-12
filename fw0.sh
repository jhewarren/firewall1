#!/bin/bash

# define user parameters
IPT="/sbin/$IPT"
## internet
exif="en0"
exip="10.100.5.0/24"
## internal
inif="enp0s8"
inip="192.168.10.0/24"
tcp_="15,21,22,53,80,443"
udp_="22"
icmp_="0,8"
drop_="23"
like_its_hot="DROP"

#TODO For FTP and SSH services, set control connections to "Minimum Delay" and FTP data
to "Maximum Throughput".
function nat_setup(){
	#TODO ifconfig config stuff
	#TODO route config stuff
}

function reset(){
	$IPT -F
	$IPT -X
	$IPT -Z
}

function default(){
	$IPT --policy INPUT $like_its_hot
	$IPT --policy FORWARD $like_its_hot
	$IPT --policy OUTPUT $like_its_hot
}

function chain(){
	$IPT -N tcp_chain
	$IPT -N udp_chain
	$IPT -N icmp_chain
	$IPT -N no_chain
}

function drop{
	#Do not accept any packets with a source address from the outside matching your internal network.
	$IPT -A FORWARD -i $exif -s $inip -j no_chain

	#Drop connections that are coming the “wrong” way (i.e., inbound SYN packets to high ports).
	#TODO how high is high?

	#Drop all packets destined for the firewall host from the outside.
	#TODO

	#Drop all TCP packets with the SYN and FIN bit set.
	$IPT -A FORWARD -i $inif -o $exif --tcp-flag SYN,FIN SYN,FIN -j no_chain
	$IPT -A FORWARD -o $inif -i $exif --tcp-flag SYN,FIN SYN,FIN -j no_chain
	
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
	for i in $drop_ do
		$IPT -A FORWARD -i $inif -o $exif -p tcp --dport $i -j no_chain
		$IPT -A FORWARD -o $inif -i $exif -p tcp --sport $i -j no_chain
		$IPT -A FORWARD -i $inif -o $exif -p udp --dport $i -j no_chain
		$IPT -A FORWARD -o $inif -i $exif -p udp --sport $i -j no_chain
	done

	$IPT -A no_chain -j DROP
}

function tcp(){
	echo "TCP ports"
	for i in $tcp_ do
		$IPT -A FORWARD -i $inif -o $exif -p tcp --dport $i -m state --state NEW,ESTABLISHED -j tcp_chain
		$IPT -A FORWARD -o $inif  -i $exif -p tcp --sport $i -m state --state NEW,ESTABLISHED -j tcp_chain
	done
	$IPT -A tcp_chain -j ACCEPT
	echo "tcp done"
	echo "---------"
}

function udp(){
	echo "udp types"
	for i in $udp_ do
		$IPT -A FORWARD -i $inif -o $exif -p udp --dport $i -m state --state NEW,ESTABLISHED -j udp_chain
		$IPT -A FORWARD -o $inif  -i $exif -p udp --sport $i -m state --state NEW,ESTABLISHED -j udp_chain
	done
	$IPT -A udp_chain -j ACCEPT
	#TODO accept fragments
	echo "udp done"
	echo "---------"
}

function icmp(){
	echo "icmp types"
	for i in $icmp_ do
		$IPT -A FORWARD -i $inif -o $exif -p icmp --icmp-type $i -m state --state NEW,ESTABLISHED -j icmp_chain
		$IPT -A FORWARD -o $inif  -i $exif -p icmp --icmp-type $i -m state --state NEW,ESTABLISHED -j icmp_chain
	done
	$IPT -A icmp_chain -j ACCEPT
	echo "icmp done"
	echo "---------"
}