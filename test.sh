#!/bin/bash

exif="en0"
inif="enp0s8"
_AB="192.168"
exnet="$_AB.0"
innet="$_AB.10"
_ws="5"
exip="$exnet.$_ws"
inip="$innet.$_ws"
echo
echo "EX: $exif $exip $exnet.0/24"
echo "IN: $inif $inip $innet.0/24"
echo
