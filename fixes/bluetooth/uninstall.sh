#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Remove the Jolla Tablet Bluetooth fix. Run as root:  devel-su sh uninstall.sh
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root
rm -f /usr/local/bin/tablet-bt-first-pairing /etc/systemd/system/tablet-bt-first-pairing.service \
      /etc/udev/rules.d/81-tablet-bt-first-pairing.rules
rm -f /etc/systemd/system/bluetooth.service.d/tablet-uinput.conf
rmdir /etc/systemd/system/bluetooth.service.d 2>/dev/null
systemctl daemon-reload
/usr/sbin/udevadm control --reload
echo "Removed. Bluetooth stays switched on; devices already paired keep working."
