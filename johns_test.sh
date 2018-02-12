#!/bin/bash

exif="en0"
inif="enp0s8"
_AB="192.168"
exnet="$_AB.0"
innet="$_AB.10"
_ws="5"
exip="$exnet.$_ws"
inip="$innet.$_ws"

function config_net(){
    echo
    echo "EX: $exif $exip $exnet.0/24"
    echo "IN: $inif $inip $innet.0/24"
    echo
    echo "ip addr add $inip dev $inif"
    echo "ip link set $inif up"
#    echo "1" > /proc/sys/net/ipv4/ip_forward
    echo "ip route add $innet.0/24 via $inip dev $inif"
    echo "ip route add $exnet.0/24 via $exip dev $exif"
}

config_net
