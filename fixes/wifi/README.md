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

The adapter does not always come up with the same address. On some boots the
driver registers `wlan0` with a wrong address, the real one shifted by one hex
digit. On others it registers the real one. connman files every saved network
under the address it saw when it started. A network saved on a "real address"
boot is unknown on a "shifted address" boot, and the other way round. In the
UI you see the network asking for its password again.

Copying the saved network's directory to the other address is not enough. The
settings file inside starts with a section header that names the address, and
connman looks the network up by that header. With the old header in place
connman reports the copied network as not saved (`Favorite: false`).

**Fix:** right before connman starts, a script mirrors every saved network to
every address the adapter is known to use, and rewrites the header in each
copy. Whichever address connman sees on this boot, all networks are there.
The newer entry wins, so a changed password follows along.

## Install

    devel-su sh install.sh

Then reboot.

## Check that it worked

After the reboot WiFi should connect by itself within a minute. As root:

    journalctl -u connman | grep wifi-mirror

shows the addresses it handled and how many entries it wrote.

    journalctl -u wifi-boot-kick

shows whether fault 1 happened on this boot. `cycling WiFi` means it did and
the service fixed it. `nothing to do` means connman won the race this time.

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

An earlier version of this fix set the real address with a udev rule when
`wlan0` appeared. On a boot with that rule in place connman still filed its
active network under the shifted address. The rule is gone.
