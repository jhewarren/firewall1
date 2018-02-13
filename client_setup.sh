#!/bin/bash
source config.sh >/dev/null

function set_client_firewall(){
    $IPT -F
    $IPT -X
    $IPT -Z

    $IPT --policy INPUT ACCEPT
    $IPT --policy FORWARD ACCEPT
    $IPT --policy OUTPUT ACCEPT

#    ifconfig $inif $client_ip up
}

function set_client_if(){
    echo IN: $inif $client_ip $insub.0/24

    ifconfig $exif down

    ip addr add $client_ip dev $inif
    ip link set $inif up
    echo "1" > /proc/sys/net/ipv4/ip_forward
    ip route add $insub.0/24 via $inip dev $inif
    route add default gw $infw
}


function restore_client(){
    ifconfig $inif down
    ifconfig $exif up
    ip route add $exsub.0/24 via $exip dev $exif
    route add default gw $exfw
}

case "$1" in
        test)
            set_client_firewall
            set_client_if
            ;;

        restore)
            restore_client
            ;;

        *)
            echo $"Usage: $0 {test|restore}"
            exit 1

esac
