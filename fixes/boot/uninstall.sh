#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Put the zram units back. Run as root:  devel-su sh uninstall.sh
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root
systemctl unmask zram.service dev-zram0.swap dev-zram1.swap dev-zram2.swap dev-zram3.swap >/dev/null 2>&1
echo "Unmasked. The ordering loop is back at the next boot."
