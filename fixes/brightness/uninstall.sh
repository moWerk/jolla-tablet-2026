#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Remove the Jolla Tablet brightness fix. Run as root:  devel-su sh uninstall.sh
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root
systemctl disable tablet-backlight.service >/dev/null 2>&1
rm -f /usr/local/bin/tablet-backlight-helper /usr/local/bin/tablet-backlight-mount \
      /etc/systemd/system/tablet-backlight.service /etc/tablet-backlight.conf
systemctl daemon-reload
echo "Removed. Reboot to get the stock behaviour back."
