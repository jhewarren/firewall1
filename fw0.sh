#!/bin/bash

# define user parameters
## internet
exif="en0"
exip="10.100.5.0/24"
## internal
inif="enp0s8"
inip="10.100.15.0/24"
tcp_=(21 22 15)
udp_=(22)
icmp=()

function user_settings(){
    echo "extranet: $exif:$exip"
    echo "---------"
    echo "intranet: $inif:$inip"
    echo "---------"


    echo "TCP ports"
    for i in "${tcp_[@]}"
    do
        echo "$i"
    done
    echo "tcp done"
    echo "---------"

    echo "udp types"
    for i in "${udp_[@]}"
    do
        echo "$i"
    done
    echo "udp done"
    echo "---------"


    echo "icmp types"
    for i in "${icmp[@]}"
        do
            echo "$i"
        done
    echo "icmp done"
    echo "---------"
}

user_settings