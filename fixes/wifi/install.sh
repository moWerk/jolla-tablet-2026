#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet WiFi fixes. Run on the tablet as root:  devel-su sh install.sh
# Safe to run twice. Undo with uninstall.sh. Both fixes act at boot: reboot after.
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root; need_tablet
export PATH=/usr/sbin:/sbin:$PATH

# The tablet's real WiFi address is stored without colons in /config/wifi/mac.txt.
raw=$(tr -d ' \r\n' < /config/wifi/mac.txt 2>/dev/null | tr 'A-F' 'a-f')
echo "$raw" | grep -qE '^[0-9a-f]{12}$' || die "/config/wifi/mac.txt does not hold a 12 digit address: '$raw'"
mac=$(echo "$raw" | sed 's/\(..\)/\1:/g; s/:$//')
echo "real WiFi address of this tablet: $mac"

echo "1/3 pin the real address when wlan0 appears"
cat > /etc/udev/rules.d/80-wlan0-real-mac.rules <<RULE
# Jolla Tablet: the bcm4330 driver registers wlan0 with a wrong address first
# (the real one shifted by one hex digit). connman files saved networks under
# the address it sees first, so they vanish when the order changes. Pin the
# real address at registration, before connman starts.
ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan0", RUN+="/usr/sbin/ip link set dev wlan0 address $mac"
RULE
chmod 644 /etc/udev/rules.d/80-wlan0-real-mac.rules
udevadm control --reload

echo "2/3 make networks saved under the wrong address visible under the real one"
C=/home/$(main_user)/.local/share/system/privileged/connman
n=0
for d in "$C"/wifi_*_managed_*; do
    [ -d "$d" ] || continue
    b=$(basename "$d"); ident=$(echo "$b" | cut -d_ -f2)
    [ "$ident" = "$raw" ] && continue
    t="$C/wifi_${raw}_$(echo "$b" | cut -d_ -f3-)"
    [ -e "$t" ] || { cp -a "$d" "$t"; n=$((n+1)); }
done
echo "    copied $n saved network(s). The old ones stay; they are harmless."

echo "3/3 retry the WiFi power-on that connman loses at boot"
install -m 755 wifi-boot-kick.sh /usr/local/bin/wifi-boot-kick.sh
install -m 644 wifi-boot-kick.service /etc/systemd/system/wifi-boot-kick.service
systemctl daemon-reload
systemctl enable wifi-boot-kick.service >/dev/null 2>&1

echo "Installed. Reboot the tablet. WiFi should come up by itself within a minute."
