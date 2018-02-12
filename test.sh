#Usage ./test <IP of target>

test="hping3 $1 -V"

#SYN FIN test
$test -c 1 -s 1000 -p 80 -SF &

#Telnet
$test -c 1 -S -s 80 -p 23 &

#Block all external traffic directed to TCP ports 32768 – 32775, 137 – 139
$test -c 7 -S -p 32768-32775 -s 80 &
$test -c 2 -S -p 137-139 -s 80 &

##Block all external traffic directed to UDP ports 32768 – 32775, 137 – 139
$test -c 7 --udp -S -p 32768-32775 -s 80 &
$test -c 2 --udp -S -p 137-139 -s 80 &

##Block all external traffic directed to TCP ports 111 and 515.
$test -c 1 -S -p 111 -s 80 &
$test -c 1 -S -p 515 -s 80 &

#Spoof subnet
$test -c 1 -S -s 80 -p 80 --spoof 192.168.10.5