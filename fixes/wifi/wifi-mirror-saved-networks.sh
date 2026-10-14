#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet: make every saved WiFi network known under the address connman
# is about to see the adapter with.
#
# The bcm4330 driver registers wlan0 early in the boot with one of three
# addresses: the real one, the real one shifted by one hex digit, or one that
# looks random. The firmware sets the real address later, when connman powers
# WiFi, but connman files each saved network under the address it saw at its
# start and keeps it. A network saved under another address is unknown on
# that boot: the UI asks for the password again.
#
# Runs right before connman starts. wlan0 is registered a few seconds earlier,
# so its address now is the one connman will see. For every saved network the
# newest entry is copied to the real, the shifted and the current address. The
# section header inside the settings file names the address, and connman looks
# the network up by that header, so the header is rewritten. A plain copy of
# the directory is not recognised. Entries under any other address are left
# over from earlier random boots; once copied, they are removed.

for u in nemo defaultuser; do [ -d /home/$u/.local/share/system/privileged/connman ] && C=/home/$u/.local/share/system/privileged/connman; done
[ -n "$C" ] || exit 0

# Android's side writes mac.txt during the boot, often after connman has
# started. Remember the address from a boot where it was there.
CACHE=/var/lib/tablet-wifi/real-address
real=$(tr -d ' \r\n' < /config/wifi/mac.txt 2>/dev/null | tr 'A-F' 'a-f')
if echo "$real" | grep -qE '^[0-9a-f]{12}$'; then
    [ "$(cat $CACHE 2>/dev/null)" = "$real" ] || { mkdir -p ${CACHE%/*} && echo "$real" > $CACHE; }
else
    real=$(cat $CACHE 2>/dev/null)
    echo "$real" | grep -qE '^[0-9a-f]{12}$' || real=
fi
shifted=$(echo "$real" | sed 's/^\(.\)\(.*\).$/\1\1\2/')
# wlan0 is normally there 4 s before connman starts. Wait a little if not.
i=0
while [ ! -e /sys/class/net/wlan0/address ] && [ $i -lt 10 ]; do sleep 1; i=$((i + 1)); done
current=$(tr -d ':\n' < /sys/class/net/wlan0/address 2>/dev/null | tr 'A-F' 'a-f')
echo "$current" | grep -qE '^[0-9a-f]{12}$' && [ "$current" != 000000000000 ] || current=
idents=$(printf '%s\n' $real $shifted $current | sort -u)
[ -n "$idents" ] || exit 0

# Repair first: an entry whose header names another identity than its
# directory is one that somebody copied by hand. connman ignores it.
r=0
for d in "$C"/wifi_*_managed_*; do
    [ -f "$d/settings" ] || continue
    b=${d##*/}
    case "$(head -1 "$d/settings")" in
        "[$b]") ;;
        "[wifi_"*) sed -i "1s/.*/[$b]/" "$d/settings" && r=$((r + 1)) ;;
    esac
done

n=0
for d in "$C"/wifi_*_managed_*; do
    [ -f "$d/settings" ] || continue
    b=${d##*/}; src=$(echo "$b" | cut -d_ -f2); rest=$(echo "$b" | cut -d_ -f3-)
    for t in $idents; do
        [ "$t" = "$src" ] && continue
        T="$C/wifi_${t}_${rest}"
        if [ ! -f "$T/settings" ] || [ "$d/settings" -nt "$T/settings" ]; then
            mkdir -p "$T" && chmod 700 "$T"
            sed "s/^\[wifi_${src}_/[wifi_${t}_/" "$d/settings" > "$T/settings.new" \
                && chmod 600 "$T/settings.new" && mv "$T/settings.new" "$T/settings" \
                && touch -r "$d/settings" "$T/settings" && n=$((n + 1))
        fi
    done
done

# Leftovers from earlier random boots. Only with the real address known, and
# only when the real entry exists, so nothing is lost.
x=0
if [ -n "$real" ]; then
    for d in "$C"/wifi_*_managed_*; do
        b=${d##*/}; src=$(echo "$b" | cut -d_ -f2); rest=$(echo "$b" | cut -d_ -f3-)
        echo "$idents" | grep -qx "$src" && continue
        [ -f "$C/wifi_${real}_${rest}/settings" ] && rm -rf "$d" && x=$((x + 1))
    done
fi

kind=other; [ "$current" = "$real" ] && kind=real; [ "$current" = "$shifted" ] && kind=shifted
[ -z "$current" ] && kind=none
msg="wifi-mirror: wlan0 address now: $kind, $r headers repaired, $n entries written, $x leftovers removed"
echo "$msg"
# The boot journal is small and volatile; keep the line where it can be read later.
echo "$(date +%T) $msg" > /run/wifi-mirror.status
exit 0
