#!/bin/sh
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Jolla Tablet: make every saved WiFi network known under every address
# connman may see the adapter with.
#
# The bcm4330 driver sometimes registers wlan0 with a wrong address (the real
# one shifted by one hex digit) and sometimes with the real one. connman files
# each saved network under the address it saw at its start. A network saved on
# a "real address" boot is unknown on a "shifted address" boot and the other
# way round: the UI asks for the password again.
#
# Runs right before connman starts. For every saved network and every address
# identity, it creates the missing counterpart or refreshes an older one. The
# section header inside the settings file names the identity, and connman looks
# the network up by that header, so the header is rewritten. A plain copy of
# the directory is not recognised.

for u in nemo defaultuser; do [ -d /home/$u/.local/share/system/privileged/connman ] && C=/home/$u/.local/share/system/privileged/connman; done
[ -n "$C" ] || exit 0

real=$(tr -d ' \r\n' < /config/wifi/mac.txt 2>/dev/null | tr 'A-F' 'a-f')
echo "$real" | grep -qE '^[0-9a-f]{12}$' || real=
# The wrong address seen so far: the first digit doubled, the last one dropped.
shifted=$(echo "$real" | sed 's/^\(.\)\(.*\).$/\1\1\2/')
seen=$(ls -d "$C"/wifi_*_managed_* 2>/dev/null | sed 's/.*\/wifi_\([0-9a-f]*\)_.*/\1/')
idents=$(printf '%s\n' $real $shifted $seen | grep -E '^[0-9a-f]{12}$' | sort -u)

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
echo "wifi-mirror: identities $(echo $idents | tr '\n' ' '), $r headers repaired, $n network entries written"
exit 0
