#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet WiFi fixes. Run on the tablet as root:  devel-su sh install.sh
# Safe to run twice. Undo with uninstall.sh. Both fixes act at boot: reboot after.
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root; need_tablet
export PATH=/usr/sbin:/sbin:$PATH

echo "1/2 keep saved networks known whichever address the adapter comes up with"
install -m 755 wifi-mirror-saved-networks.sh /usr/local/bin/wifi-mirror-saved-networks.sh
mkdir -p /etc/systemd/system/connman.service.d
install -m 644 connman-mirror.conf /etc/systemd/system/connman.service.d/tablet-wifi-mirror.conf
# An earlier version of this fix pinned the address with a udev rule. It did
# not decide which address connman sees. Remove it.
rm -f /etc/udev/rules.d/80-wlan0-real-mac.rules; udevadm control --reload
/usr/local/bin/wifi-mirror-saved-networks.sh

echo "2/2 retry the WiFi power-on that connman loses at boot"
install -m 755 wifi-boot-kick.sh /usr/local/bin/wifi-boot-kick.sh
install -m 644 wifi-boot-kick.service /etc/systemd/system/wifi-boot-kick.service
systemctl daemon-reload
systemctl enable wifi-boot-kick.service >/dev/null 2>&1

echo "Installed. Reboot the tablet. WiFi should come up by itself within a minute."
