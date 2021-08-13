#!/bin/sh

grepzt() {
  (find /proc -name exe | xargs -I{} readlink {}) 2>/dev/null | grep -q zerotier-one
  return $?
}

echo "starting zerotier"
setsid /usr/sbin/zerotier-one &

while ! grepzt
do
  echo "zerotier hasn't started, waiting a second"
  sleep 1
done

#echo "joining networks: $ZT_NETWORK"

echo "joining $ZT_NETWORK"

while ! zerotier-cli join "$ZT_NETWORK"
do 
    echo "joining $ZT_NETWORK failed; trying again in 1s"
    sleep 1
done
# Print Client Info
echo "$(zerotier-cli info)"

# Set IPTables to allow NATting
sysctl -w net.ipv4.ip_forward=1 > /dev/null
PHY_IFACE=eth0; ZT_IFACE=$(ls /sys/class/net | grep ^zt)

iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE
iptables -A FORWARD -i $PHY_IFACE -o $ZT_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $ZT_IFACE -o $PHY_IFACE -j ACCEPT

sleep infinity