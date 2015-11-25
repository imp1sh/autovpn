# autovpn
automatically connects your openvpn connection if you're not already connected to a specific (remote) network.

# how
invoke manually or for automatic start put it into /etc/rc.local like so
/usr/bin/screen -dmS autovpn /home/thatsme/autovpn/autovpn.bash /etc/openvpn/myvpn/myvpn.conf apingableipfromthatremotenet
