#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet full brightness range. Run on the tablet as root:  devel-su sh install.sh
# Safe to run twice. Undo with uninstall.sh. Takes effect after a reboot.
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root; need_tablet
[ -e /sys/bus/platform/devices/80860F09:00/test_write ] \
    || die "the PWM debug attribute this fix relies on is missing. Nothing was changed."
[ -e /sys/class/backlight/intel_backlight/brightness ] || die "no intel_backlight device. Nothing was changed."
command -v python3 >/dev/null || die "python3 is missing. Install it first: pkcon install python3"

install -m 755 tablet-backlight-helper /usr/local/bin/tablet-backlight-helper
install -m 755 tablet-backlight-mount  /usr/local/bin/tablet-backlight-mount
install -m 644 tablet-backlight.service /etc/systemd/system/tablet-backlight.service
[ -e /etc/tablet-backlight.conf ] || install -m 644 tablet-backlight.conf /etc/tablet-backlight.conf
systemctl daemon-reload
systemctl enable tablet-backlight.service >/dev/null 2>&1

echo "Installed. Reboot the tablet."
echo "After the reboot the slider reaches from barely visible to brighter than before."
echo "The low end is now very dark: if the screen looks off in daylight, raise the slider."
