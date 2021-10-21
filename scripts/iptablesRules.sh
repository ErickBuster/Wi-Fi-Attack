iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $out_interface -j MASQUERADE
iptables --append FORWARD --in-interface ${interface_set}mon -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $(/usr/sbin/ifconfig | grep ${out_interface} -A 1 | grep inet | awk '{print $2}'):80
echo 1 > /proc/sys/net/ipv4/ip_forward
