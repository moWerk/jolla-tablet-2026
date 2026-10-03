#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet: switch Bluetooth on through connman, which is what keeps it off.
# Run as root:  devel-su sh enable.sh      The setting survives reboots.
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root; need_tablet
dbus-send --system --print-reply --dest=net.connman /net/connman/technology/bluetooth \
    net.connman.Technology.SetProperty string:Powered variant:boolean:true >/dev/null \
    && echo "Bluetooth powered on through connman." \
    || die "connman did not accept the request"
