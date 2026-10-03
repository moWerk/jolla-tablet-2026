#!/bin/bash
# Jolla Tablet: retry the WiFi power-on that connman loses at boot.
#
# At boot connman powers WiFi while Android's wlan_prov still holds the chip in
# reset. connman logs "statechange notify fail" and never retries. The UI then
# shows WiFi on and no networks, with wlan0 down. A manual toggle cures it.
# This does the toggle: wait for wlan_prov to finish, and only if connman says
# Powered while wlan0 is down, switch WiFi off and on over connman's D-Bus API.
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
T="dbus-send --system --print-reply --dest=net.connman /net/connman/technology/wifi"
for i in $(seq 90); do
  [ "$(getprop init.svc.wlan_prov 2>/dev/null)" = "stopped" ] && break
  sleep 1
done
sleep 5
powered=$($T net.connman.Technology.GetProperties 2>/dev/null | grep -A1 '"Powered"' | grep -oE 'true|false')
flags=$(cat /sys/class/net/wlan0/flags 2>/dev/null || echo 0)
up=$(( flags & 1 ))
echo "wlan_prov=$(getprop init.svc.wlan_prov) powered=$powered wlan0_admin_up=$up"
if [ "$powered" = "true" ] && [ "$up" = "0" ]; then
  echo "connman says Powered but wlan0 is down: cycling WiFi"
  $T net.connman.Technology.SetProperty string:Powered variant:boolean:false >/dev/null
  sleep 3
  $T net.connman.Technology.SetProperty string:Powered variant:boolean:true >/dev/null
  sleep 6
  echo "after: $(ip -br link show wlan0)"
else
  echo "nothing to do"
fi
