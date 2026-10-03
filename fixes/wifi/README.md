# WiFi

Two faults. Both are in software above the radio. The radio itself is fine: the
chip comes up in 0.3 s and associates in seconds when asked properly.

## Fault 1: WiFi is on, but there are no networks

At boot connman powers WiFi at about 19 s. At that moment Android's `wlan_prov`
service still holds the chip in reset. connman logs `statechange notify fail`
and never tries again. It then believes WiFi is on while `wlan0` is down. The
UI shows WiFi on and an empty network list. Toggling WiFi cures it until the
next boot.

**Fix:** a small service waits until `wlan_prov` has finished. If connman says
WiFi is powered while `wlan0` is down, it switches WiFi off and on once.

## Fault 2: saved networks vanish

The driver registers `wlan0` with a wrong address first. It is the real address
shifted by one hex digit. Later the firmware brings up the real address.
connman stores each saved network under the address it saw first. Normally that
is the wrong one. During an OS update connman restarts while WiFi is already
up, so networks saved then land under the real address. After the next reboot
they are invisible. In the UI you see a favourite that never connects next to
the same network asking for its password again.

**Fix:** a udev rule sets the real address the moment `wlan0` appears, before
connman starts. The installer reads the real address from
`/config/wifi/mac.txt`. It also copies networks saved under any other address
to the real one, so nothing has to be typed again.

## Install

    devel-su sh install.sh

Then reboot.

## Check that it worked

After the reboot WiFi should connect by itself within a minute. As root:

    dmesg | grep "register interface"

The address shown must be the one from `/config/wifi/mac.txt`.

    journalctl -u wifi-boot-kick

This shows whether the race happened on this boot. `cycling WiFi` means it did
and the service fixed it. `nothing to do` means connman won the race this time.

## Remove

    devel-su sh uninstall.sh

## What was measured

On the test tablet, one boot with both fixes: the driver registered the real
address at 6.8 s. connman logged `statechange notify fail`. `wlan_prov` exited
five seconds later. The service found WiFi powered with `wlan0` down, cycled
it, and `wlan0` was up eleven seconds after that. Nobody touched the tablet.

One more message stays in the kernel log on every boot:
`dhd_preinit_ioctls: can't set MAC address, error=-21`. No effect was seen.
