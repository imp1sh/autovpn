#!/bin/bash
# autovpn
# read and understand
# Jochen Demmer
#
# define from here
# if ping is not successfull, sleep for seconds given:
pingsleeptimer=60
# if network interface is not up, sleep for seconds given:
ifupsleeptimer=10
# give the network interfaces that shall be checked:
checkifs=( 'enp0s25' 'wlp3s0' )

# do not change from here
function tellhow {
	echo "First parameter is path to vpn config."
	echo "Second parameter is a host in your destination network that is up and reachable via ICMP type 8, i.e. ping."
}

function testing {
	echo "`$0`"
}
if [ -z $1 ]; then
	tellhow
	exit 1
fi
if [ -z $2 ]; then
	tellhow
	exit 1
fi

echo "`date` $0 Initializing script."
echo "`date` $0 Waiting for network to come up"

while [ true ]; do
	x=0
	for i in "${checkifs[@]}"; do
#		if [ `ip a s $i |grep state |grep -c UP` -gt 0 ]; then
		if [ `cat /sys/class/net/$i/operstate |grep -c up` -gt 0 ]; then
			echo "`date` $0 interface $i seems to be up."
			((x++))
		else
			echo "`date` $0 interface $i seems to be down."
			sleep 1
		fi
	done
	if [ $x -gt 0 ]; then
		if [ `ping -c 5 8.8.8.8 | grep -c "bytes from"` -gt 3 ]; then
			echo "`date` $0 there seem to be internet available."
			break
		else
			echo "`date` $0 there is no internet. I'll keep trying, interval $ifupsleeptimer seconds."
			sleep $ifupsleeptimer
		fi
	fi
done

while  [ true ]; do
	if [ `ping -c 5 $2 |grep -c "bytes from"` -gt 3 ]; then
		# echo "ping to $2 at least 4 out of 5 times ok"
		echo "`date` $0 Already connected to destination network."
	else
		# echo "ping to $2 at least 2 out of 5 times not ok"
		echo "`date` $0 Starting vpn connection"
		openvpn --config $1
	fi
	echo "`date` $0 Remote network not reachable. I'll keep trying, interval $pingsleeptimer seconds."
	sleep $pingsleeptimer
done
