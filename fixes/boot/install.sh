#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet: remove the ordering loop from the boot by masking the zram
# units. Run on the tablet as root:  devel-su sh install.sh
# Safe to run twice. Undo with uninstall.sh. Takes effect at the next boot.
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root; need_tablet
UNITS="zram.service dev-zram0.swap dev-zram1.swap dev-zram2.swap dev-zram3.swap"
systemctl mask $UNITS >/dev/null 2>&1
for u in $UNITS; do
    [ "$(systemctl is-enabled $u 2>/dev/null)" = masked ] || die "$u is not masked"
done
echo "Masked: $UNITS"
echo "Reboot. The tablet had no working swap before and has none now."
