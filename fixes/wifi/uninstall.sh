#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Remove the Jolla Tablet WiFi fixes. Run as root:  devel-su sh uninstall.sh
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root
systemctl disable wifi-boot-kick.service >/dev/null 2>&1
rm -f /usr/local/bin/wifi-boot-kick.sh /etc/systemd/system/wifi-boot-kick.service \
      /usr/local/bin/wifi-mirror-saved-networks.sh /etc/systemd/system/connman.service.d/tablet-wifi-mirror.conf \
      /etc/udev/rules.d/80-wlan0-real-mac.rules
rmdir /etc/systemd/system/connman.service.d 2>/dev/null
systemctl daemon-reload
/usr/sbin/udevadm control --reload
echo "Removed. The mirrored network entries were left in place; they are harmless. Reboot."
