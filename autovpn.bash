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
scriptname=$0
function logdo {
	echo "`date` $scriptname $1"
}
function tellhow {
	logdo "First parameter is path to vpn config."
	logdo "Second parameter is a host in your destination network that is up and reachable via ICMP type 8, i.e. ping."
}


if ( [ -z $1 ] || [ -z $2 ] ); then
	logdo "Script failed."
	tellhow
	exit 1
fi

logdo "Initializing script."
logdo "Waiting for network to come up."

# check if interface is up
while [ true ]; do
	x=0
	for i in "${checkifs[@]}"; do
#		if [ `ip a s $i |grep state |grep -c UP` -gt 0 ]; then
		if [ `cat /sys/class/net/$i/operstate |grep -c up` -gt 0 ]; then
			logdo "interface $i seems to be up."
			((x++))
		else
			logdo "Interface $i seems to be down."
			sleep 1
		fi
	done
	if [ $x -gt 0 ]; then
		if [ `ping -c 5 8.8.8.8 | grep -c "bytes from"` -gt 3 ]; then
			logdo "Internet connection seems to be working."
			break
		else
			logdo "Internet connection seems NOT to be working. I'll keep trying, interval $ifupsleeptimer seconds."
			sleep $ifupsleeptimer
		fi
	fi
done

# check if you're not already connected to that network
while  [ true ]; do
	if [ `ping -c 5 $2 |grep -c "bytes from"` -gt 3 ]; then
		# echo "ping to $2 at least 4 out of 5 times ok"
		logdo "Already connected to destination network."
	else
		# echo "ping to $2 at least 2 out of 5 times not ok"
		logdo "Starting vpn connection"
		openvpn --config $1
	fi
	echo "`date` $0 Remote network not reachable. I'll keep trying, interval $pingsleeptimer seconds."
	sleep $pingsleeptimer
done
