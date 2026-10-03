#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet Bluetooth fixes. Run on the tablet as root:  devel-su sh install.sh
# Safe to run twice. Undo with uninstall.sh. No reboot needed.
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root; need_tablet
command -v python3 >/dev/null || die "python3 is missing. Install it first: pkcon install python3"

echo "1/3 make a first pairing possible"
install -m 755 tablet-bt-first-pairing /usr/local/bin/tablet-bt-first-pairing
install -m 644 tablet-bt-first-pairing.service /etc/systemd/system/tablet-bt-first-pairing.service
install -m 644 81-tablet-bt-first-pairing.rules /etc/udev/rules.d/81-tablet-bt-first-pairing.rules
systemctl daemon-reload
/usr/sbin/udevadm control --reload

install -m 755 bt-tether /usr/local/bin/bt-tether

echo "2/3 let bluetoothd receive the buttons of a headset"
mkdir -p /etc/systemd/system/bluetooth.service.d
install -m 644 tablet-uinput.conf /etc/systemd/system/bluetooth.service.d/tablet-uinput.conf
systemctl daemon-reload
systemctl restart bluetooth.service; sleep 2

echo "3/3 switch Bluetooth on through connman, which is what keeps it off"
T="dbus-send --system --print-reply --dest=net.connman /net/connman/technology/bluetooth net.connman.Technology.SetProperty string:Powered"
# Off and on, so that the adapter appears anew and the rule above fires.
$T variant:boolean:false >/dev/null 2>&1; sleep 3
$T variant:boolean:true >/dev/null 2>&1 || die "connman did not accept the request"
i=0; while [ ! -e /sys/class/bluetooth/hci0 ] && [ $i -lt 20 ]; do sleep 1; i=$((i + 1)); done
[ -e /sys/class/bluetooth/hci0 ] || die "the adapter did not appear"
sleep 6
echo "Installed. Bluetooth is on. Pair from Settings as usual."
