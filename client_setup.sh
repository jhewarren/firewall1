#!/bin/bash
source config.sh

$IPT -F
$IPT -X
$IPT -Z

$IPT --policy INPUT ACCEPT
$IPT --policy FORWARD ACCEPT 
$IPT --policy OUTPUT ACCEPT

ifconfig $exif down
ifconfig $inif 192.168.1.2 up
route add defualt gw $firewall_ip