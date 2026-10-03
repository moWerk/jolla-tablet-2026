#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet: remove the ordering loop from the boot by correcting
# zram.service. Run on the tablet as root:  devel-su sh install.sh
# Safe to run twice. Undo with uninstall.sh. Takes effect at the next boot.
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root; need_tablet
UNITS="zram.service dev-zram0.swap dev-zram1.swap dev-zram2.swap dev-zram3.swap"
# An earlier version of this fix masked the units. Undo that first.
systemctl unmask $UNITS >/dev/null 2>&1
install -m 644 zram.service /etc/systemd/system/zram.service
systemctl daemon-reload
systemctl cat zram.service 2>/dev/null | grep -q "^After=local-fs.target" && die "the corrected unit is not the one systemd uses"
echo "Installed /etc/systemd/system/zram.service. Reboot."
echo "After the reboot: 'cat /proc/swaps' lists four zram devices."
