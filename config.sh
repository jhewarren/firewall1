#!/bin/bash
# define user parameters
export IPT="/sbin/$IPT"
## internet
export exif="eno1"
export exip="192.168.0.0/24"

## internal
export inif="enp3s2"
export inip="192.168.1.0/24"
export firewall_ip="192.168.1.1"
	#ports
	export tcp_="15,21,22,53,80,443"
	export udp_="22"
	export icmp_="0,8"
	export drop_="23"