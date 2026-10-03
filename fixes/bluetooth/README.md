# Bluetooth

Bluetooth never comes up. Everything needed is installed, and the adapter
`hci0` simply never appears.

## Cause

connman owns the radio switches. Its stored settings say Bluetooth is disabled,
and it enforces that. Whatever clears the block, connman sets it again within
seconds. `rfkill unblock` always loses.

## Fix

Ask connman itself to power Bluetooth. connman also remembers that.

    devel-su sh enable.sh

That is one D-Bus call:

    dbus-send --system --print-reply --dest=net.connman \
        /net/connman/technology/bluetooth \
        net.connman.Technology.SetProperty string:Powered variant:boolean:true

## Check

    busctl get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered

There is no `bluetoothctl` and no `hciconfig` on the tablet. The chip is a
BCM4330: Bluetooth 4.0 with Low Energy.

A message `bcm_bt_lpm ... Error evaluating UART port number` appears in the
kernel log on every boot. It is not the cause.
