# Jolla Tablet in 2026

The Jolla Tablet (JT-1501) still works in 2026. It runs Sailfish OS 4.6.0.15,
the last release made for it. Out of the box several things are broken or
awkward on that release. This repository holds the fixes, one folder each, with
an installer and an uninstaller.

Everything here was found and measured on one tablet. Nothing here touches the
kernel or the boot image. Every fix can be removed again.

## What is fixed

| Problem | Cause | Fix | State |
|---|---|---|---|
| WiFi is "on" after boot but finds no networks | connman powers WiFi while Android's `wlan_prov` still holds the chip in reset, and never retries | [fixes/wifi](fixes/wifi/) | proven by reboot |
| Saved WiFi networks vanish after an update | the driver shows a wrong address first, and connman files networks under the address it sees first | [fixes/wifi](fixes/wifi/) | proven by reboot |
| The screen is too bright at the lowest setting, and the slider barely does anything | the kernel squeezes the backlight into 20 % to 64 % duty, and automatic adjustment squeezes the slider further | [fixes/brightness](fixes/brightness/) | proven by reboot |
| GPS never gets a fix once the tablet has slept | the location provider stamps injected time with the wrong clock, and the GPS daemon restarts every 54 s | [fixes/gps](fixes/gps/) | proven, files follow |
| Bluetooth never comes up | connman keeps it soft-blocked | [fixes/bluetooth](fixes/bluetooth/) | works |
| The update to 4.6 seems impossible | the UI updater is a dead end on this device | [docs/update-to-4.6.0.15.md](docs/update-to-4.6.0.15.md) | done once, seven hops |

Known and not fixed yet: [docs/open-issues.md](docs/open-issues.md).

## How to use it

Developer mode has to be on. Get the files onto the tablet, then as root:

    cd jolla-tablet-2026/fixes/wifi
    devel-su sh install.sh
    reboot

Each installer checks that it runs on a Jolla Tablet and stops with a plain
message if something is not as expected. Each folder has an `uninstall.sh` and
a README that says what was measured and how to check the result.

The login user is `nemo` on a tablet updated from an old release and
`defaultuser` on a fresh install. `devel-su` needs a real terminal; it does not
take a password from a pipe.

## Read this before you start

- **Never use "factory reset" in the recovery menu.** It reflashes Sailfish OS
  1.1.9 and the whole update path starts again.
- The fixes were made on Sailfish OS 4.6.0.15. On older releases they are
  untested.
- These are local fixes. They are not upstream, and an OS reinstall removes them.
- If the tablet hangs on the logo, hold Volume Down and Power together for more
  than 10 seconds. That forces a reboot.
- The system log lives in memory, one megabyte of it. A reboot erases it. Read
  it before you reboot: `devel-su journalctl -b`
- The userland is BusyBox. There is no `timeout`, and `ip` is in `/usr/sbin`.

## How this was made

The fixes were worked out in October 2026 by moWerk together with Claude, an
LLM, working directly on the tablet over ssh. The causes were measured on the
device, not guessed: each folder says what was measured and how to check it
yourself.
