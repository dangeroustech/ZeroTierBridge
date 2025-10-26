#!/bin/sh

set -eu

terminate() {
  # Try to terminate zerotier-one gracefully
  if [ -n "${ZT_PID:-}" ]; then
    kill -TERM "$ZT_PID" 2>/dev/null || true
    wait "$ZT_PID" 2>/dev/null || true
  fi
}
trap terminate INT TERM

echo "starting zerotier"
setsid /usr/sbin/zerotier-one &
ZT_PID=$!

# Wait for zerotier to be responsive
until zerotier-cli info >/dev/null 2>&1; do
  echo "zerotier hasn't started, waiting a second"
  sleep 1
done

# Set IPTables to allow NATting
sysctl -w net.ipv4.ip_forward=1 > /dev/null

echo "joining networks: ${ZT_NETWORKS:-}"

for n in ${ZT_NETWORKS:-}; do
  echo "joining $n"

  until zerotier-cli join "$n"; do
    echo "joining $n failed; trying again in 1s"
    sleep 1
  done

  if [ "${ZT_BRIDGE:-true}" = "true" ]; then
    ZT_IFACE=$(zerotier-cli get "$n" portDeviceName)
    PHY_IFACE=eth0
    echo "Configuring iptables on ${ZT_IFACE}"

    # idempotent rules
    iptables -t nat -C POSTROUTING -o "$PHY_IFACE" -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -o "$PHY_IFACE" -j MASQUERADE
    iptables -t nat -C POSTROUTING -o "$ZT_IFACE" -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -o "$ZT_IFACE" -j MASQUERADE
    iptables -C FORWARD -i "$PHY_IFACE" -o "$ZT_IFACE" -j ACCEPT 2>/dev/null || iptables -A FORWARD -i "$PHY_IFACE" -o "$ZT_IFACE" -j ACCEPT
    iptables -C FORWARD -i "$ZT_IFACE" -o "$PHY_IFACE" -j ACCEPT 2>/dev/null || iptables -A FORWARD -i "$ZT_IFACE" -o "$PHY_IFACE" -j ACCEPT
  fi
done

# Give ZT a second to realise it's online
sleep 10

# Print Client Info
zerotier-cli info || true

# Keep the container running while zerotier-one is alive
wait "$ZT_PID"