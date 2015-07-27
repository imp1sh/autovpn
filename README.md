# autovpn
automatically connects your openvpn connection if your not already connected to a specific remote network

# how
put it into /etc/rc.local like so
/usr/bin/screen -dmS autovpn /home/thatsme/autovpn/autovpn.bash /etc/openvpn/myvpn/myvpn.conf apingableipfromthatremotenet
