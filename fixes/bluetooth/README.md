# Bluetooth

Three faults. The adapter never comes up. Once it does, nothing can be
paired: the tablet says the other device did not answer. And the buttons of
a headset do not arrive.

## Fault 1: no adapter

Everything needed is installed, and `hci0` never appears. connman owns the
radio switches. Its stored settings say Bluetooth is disabled, and it enforces
that. Whatever clears the block, connman sets it again within seconds.
`rfkill unblock` always loses.

**Fix:** ask connman itself to power Bluetooth. It remembers that across
reboots.

## Fault 2: pairing always times out

The other device is found and connected. Then the tablet asks for
authentication, the Bluetooth chip asks the tablet "do you have a key for this
device?", and the tablet never answers. Half a minute later the attempt times
out. The other device was waiting for the tablet, not the other way round.

The answer has to come from the kernel. The tablet's kernel is from 2013, and
it only answers that question after a key list has been loaded into it once.
BlueZ in Sailfish OS 4.6 is from 2024, and it loads a key list only when it
already has a paired device. With nothing paired, nothing is loaded, the
kernel stays silent, and nothing can ever be paired.

**Fix:** when the adapter appears and no paired device is stored, a small
script loads an empty key list into the kernel. From then on the kernel
answers. Once one device is paired the script does nothing; BlueZ loads the
real keys itself.

## Fault 3: headset buttons are lost

Play, pause and skip on a headset arrive as key presses through an input
device that the Bluetooth daemon creates. On the tablet it cannot: the device
node `/dev/uinput` belongs to the Android group `net_bt_stack`, and the daemon
runs without the privilege that lets root ignore file permissions. Its log
says `AVRCP: failed to init uinput`.

**Fix:** a drop-in adds that group to the Bluetooth service. After that the
input device appears when a headset connects, named after the headset with
`(AVRCP)` at the end.

Whether a button then pauses the music depends on the player. The Media app
can be controlled this way. The browser cannot.

## Install

    devel-su sh install.sh

No reboot is needed. Then pair from Settings as usual.

## Check that it worked

    busctl get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered
    systemctl status tablet-bt-first-pairing

With nothing paired, the second line ends with
`empty key list loaded into hci0, pairing is possible now`.

## Remove

    devel-su sh uninstall.sh

## What was measured

A trace of the Bluetooth traffic during a failed pairing ends like this:

    < HCI Command: Authentication Requested
    > HCI Event: Link Key Request

and then nothing. The kernel's own debug output shows its handler for that
event returning at its first check. After an empty key list was loaded by
hand, the same attempt ran through: negative reply, capability exchange,
confirmation, pairing complete, link key stored. Audio then played on a pair
of earbuds over A2DP.

With the paired device's data moved aside, no key list reached the kernel
after a restart. With it back in place, one did.

With the fix installed on a tablet that had nothing paired, the earbuds
paired from Settings on the first attempt.

## Good to know

- Tested with one pair of earbuds, audio output only (A2DP). The headset
  profile for calls shows as not available.
- Buttons: with music playing in the Media app, a tap on the earbuds paused
  it and another tap resumed it.
- A message `bcm_bt_lpm ... Error evaluating UART port number` appears in the
  kernel log on every boot. It is not the cause of anything here.
- For looking deeper, `pkcon install bluez5-tools` brings `btmon`,
  `bluetoothctl` and `btmgmt`. The chip is a BCM4330: Bluetooth 4.0 with Low
  Energy.
