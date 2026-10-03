#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Remove the Jolla Tablet GPS fix. Run as root:  devel-su sh uninstall.sh
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root
rm -f /usr/lib/libgeoclue-boottime.so
for unit in geoclue-providers-hybris.service dbus-org.freedesktop.Geoclue.Providers.Hybris.service; do
    rm -f /etc/systemd/user/$unit.d/boottime.conf
    rmdir /etc/systemd/user/$unit.d 2>/dev/null
done
u=$(main_user)
su $u -c "XDG_RUNTIME_DIR=/run/user/$(id -u $u) systemctl --user daemon-reload" 2>/dev/null
killall geoclue-hybris 2>/dev/null
echo "Removed."
