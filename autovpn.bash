#!/bin/bash
# Jochen Demmer
checkinterval=60
checkifs=( 'bridge0', 'wlan0' )
if [ -z $1 ]; then
	echo "First parameter is path to vpn config."
	exit 1
fi
if [ -z $2 ]; then
	echo "Second parameter is host that shall be pinged in order to check if connected to this remote net."
	exit 1
fi

echo "`date` $0 initializing script"
echo "`date` $0 waiting for network to come up"


while [ true ]; do
	x=0
	for i in "${checkifs[@]}"; do
		if [ `ip a s $i |grep state |grep -c UP` -gt 0 ]; then
			echo "`date` $0 interface $i seems to be up."
			((x++))
		else
			echo "`date` $0 interface $i seems to be down."
		fi
	done
	if [ $x -gt 0 ]; then
		if [ `ping -c 5 8.8.8.8 | grep -c "bytes from"` -gt 3 ]; then
			echo "`date` $0 there seem to be internet available"
			break
		else
			echo "`date` $0 there is no internet. I'll keep trying."
		fi
	fi
done



while  [ true ]; do
	if [ `ping -c 5 $2 |grep -c "bytes from"` -gt 3 ]; then
		# echo "ping to $2 at least 4 out of 5 times ok"
		echo "`date` $0 Already connected to ha.home"
	else
		# echo "ping to $2 at least 2 out of 5 times not ok"
		echo "`date` $0 starting vpn connection"
		openvpn --config $1
	fi
	echo "`date` $0 sleeping for $checkinterval seconds"
	sleep $checkinterval
done
