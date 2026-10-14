# WiFi

Two faults. Both are in software above the radio. The radio itself is fine: the
chip comes up in 0.3 s and associates in seconds when asked properly. Neither
fault strikes on every boot.

## Fault 1: WiFi is on, but there are no networks

At boot connman powers WiFi while Android's `wlan_prov` service still holds
the chip in reset. connman logs `statechange notify fail` and never tries
again. It then believes WiFi is on while `wlan0` is down. The UI shows WiFi on
and an empty network list. Toggling WiFi cures it until the next boot.

**Fix:** a small service waits until `wlan_prov` has finished. If connman says
WiFi is powered while `wlan0` is down, it switches WiFi off and on once.

## Fault 2: saved networks vanish

The driver registers `wlan0` early in the boot, before the firmware runs, and
the address it registers with is not always the real one. In a series of 15
reboots of the test tablet it was the real address 10 times, the real one
shifted by one hex digit 2 times, and an address that looks random 3 times.
The firmware sets the real address later, when connman switches WiFi on. But
connman files every saved network under the address it saw at its start, and
keeps it. A network saved under another address is unknown on that boot. In
the UI you see the network asking for its password again. On 2 of the 3
random-address boots WiFi did not connect at all.

Copying the saved network's directory to the other address is not enough. The
settings file inside starts with a section header that names the address, and
connman looks the network up by that header. With the old header in place
connman reports the copied network as not saved (`Favorite: false`).

**Fix:** right before connman starts, a script reads the address `wlan0` has
at that moment, which is the one connman is about to see. `wlan0` is there 4
seconds before connman starts. The script copies every saved network to that
address, to the real one and to the shifted one, and rewrites the header in
each copy. The newer entry wins, so a changed password follows along. Copies
under addresses of earlier random boots are removed once the real address has
the network, so they do not pile up.

## Install

    devel-su sh install.sh

Then reboot.

## Check that it worked

After the reboot WiFi should connect by itself within a minute. As root:

    systemctl status connman | grep ExecStartPre

must show the mirror script with `status=0/SUCCESS`.

    cat /run/wifi-mirror.status /run/wifi-boot-kick.status

The first line says which address `wlan0` had when connman started (`real`,
`shifted` or `other`) and how many entries were written. The kick's lines show
whether fault 1 happened on this boot: `cycling WiFi` means it did and the
service fixed it, `nothing to do` means connman won the race this time. Both
files are also in the journal, but the journal on the tablet is small and
kept in memory only, so after a few minutes those lines are often gone.

## Remove

    devel-su sh uninstall.sh

The mirrored entries stay. They are harmless.

## What was measured

Fault 1, one boot: connman logged `statechange notify fail`. `wlan_prov`
exited five seconds later. The service found WiFi powered with `wlan0` down,
cycled it, and `wlan0` was up eleven seconds after that.

Fault 2: two boots three minutes apart registered `wlan0` once with the real
address and once with the shifted one. A copied network with the old header
showed `Favorite: false, AutoConnect: false`. With the header corrected and
connman restarted it showed `true` for both.

The fix, on a boot that came up with the shifted address: a network saved
under the real address only was present under the shifted one after the
reboot, connman listed every saved network as known, and WiFi connected
without a touch.

Fault 2, the reboot series of 2026-10-14 (test tablet, 4.6.0.15, one line per
boot recorded 90 s after the start, addresses masked):

| | boots | real | shifted | random | not connected |
|---|---|---|---|---|---|
| earlier version | 15 | 10 | 2 | 3 | 2 (both random) |
| this version | 24 | 20 | 2 | 2 | 0 |

A random address is new on every such boot. `wlan0` was registered 5.5 to 7.8 s
after the start, connman started at 10.5 to 12.5 s. connman logged `statechange
notify fail` on every boot; the kick found `wlan0` down only twice.

One random boot is not understood: when connman started, `wlan0` already had
the real address, the firmware came up late (50 s instead of 26 s), the kick
cycled WiFi, and connman then connected under the random address. It connected,
but where it found the saved network for that address is open.

Fault 2 with a random address: before this version, the fix only knew the
real and the shifted address. A forum user kept hitting the password prompt
after boots. The reboot series above found the random addresses; on the test
tablet they had not shown up in the two boots the earlier version was tested
on.

An earlier version of this fix set the real address with a udev rule when
`wlan0` appeared. On a boot with that rule in place connman still filed its
active network under the shifted address. The rule is gone.
