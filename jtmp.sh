#!/bin/bash

# define network settings
# general overview is a.b.in/ex.ws for 192.168.0.13
# a & b are generally consistent
# external subnet is 192.168.0.0/24,
# internal subnet is 192.168.10.0/24,
# so 3rd quad is internal or external

source config.sh >/dev/null


function config_net(){
    echo EX: $exif $exip $exsub.0/24
    echo IN: $inif $inip $insub.0/24
    ip addr add $inip dev $inif
    ip link set $inif up
    echo "1" > /proc/sys/net/ipv4/ip_forward
    ip route add $exsub.0/24 via $exip dev $exif
    ip route add $insub.0/24 via $inip dev $inif
}

config_net
