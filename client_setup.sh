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
    echo IN: $inif $inpc $exif $insub

    ifconfig $exif down

    ifconfig $inif $inpc up
    route add default gw $infw
#    route add $insub via $infw dev $inif
 #    ifconfig $inif up

	    echo "nameserver 8.8.8.8" > /etc/resolv.conf
}

function restore_client(){
    ip route del default
    ip route del 192.168.10.0/24
    ifconfig $inif down
    ifconfig $exif $exfw
    ifconfig $exif up
    ip route add $exsub via 192.168.0.100 dev $exif
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
