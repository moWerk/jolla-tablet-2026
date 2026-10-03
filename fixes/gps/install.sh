#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet GPS fix. Run on the tablet as root:  devel-su sh install.sh
# Safe to run twice. Undo with uninstall.sh. No reboot needed.
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root; need_tablet
SO=libgeoclue-boottime.so
[ -x /usr/libexec/geoclue-hybris ] || die "geoclue-hybris is not installed. Nothing was changed."
[ -f $SO ] || die "$SO is missing. Build it with build.sh on an x86 computer and copy it here."

# geoclue-hybris is setuid root. In that mode the loader only preloads a library
# given by bare name, from a trusted directory, that carries the setuid bit itself.
install -o root -g root -m 4755 $SO /usr/lib/$SO

U=/usr/lib/systemd/user
n=0
for unit in geoclue-providers-hybris.service dbus-org.freedesktop.Geoclue.Providers.Hybris.service; do
    [ -e $U/$unit ] || continue
    [ -L $U/$unit ] && continue        # an alias of the other unit, the one drop-in covers it
    mkdir -p /etc/systemd/user/$unit.d
    cat > /etc/systemd/user/$unit.d/boottime.conf <<CONF
# CLOCK_BOOTTIME shim for the time handed to the GPS engine.
# Bare library name on purpose: geoclue-hybris is setuid.
[Service]
Environment=LD_PRELOAD=$SO
CONF
    n=$((n + 1))
done
[ $n -gt 0 ] || die "found no geoclue-providers-hybris unit in $U. The library is installed but not loaded."

u=$(main_user)
su $u -c "XDG_RUNTIME_DIR=/run/user/$(id -u $u) systemctl --user daemon-reload" 2>/dev/null
# A running provider keeps the old behaviour. Stop it; it starts again on demand.
killall geoclue-hybris 2>/dev/null

echo "Installed. Open a maps app to start GPS. Expect minutes to the first fix."
