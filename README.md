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
| Saved WiFi networks ask for their password again | the adapter comes up with one of two addresses, and connman files networks under the one it sees | [fixes/wifi](fixes/wifi/) | proven by reboot |
| The screen is too bright at the lowest setting, and the slider barely does anything | the kernel squeezes the backlight into 20 % to 64 % duty, and automatic adjustment squeezes the slider further | [fixes/brightness](fixes/brightness/) | proven by reboot |
| The brightness jumps on every touch | Intel's `coreu` daemon re-sets the backlight ten times on every picture change (DPST) | [fixes/brightness](fixes/brightness/) | proven by trace and by eye |
| Some boots have no WiFi and no GPS, or hang on the logo; no swap | the tablet's own zram service is ordered into a loop, and systemd breaks it differently from boot to boot | [fixes/boot](fixes/boot/) | loop gone, swap works |
| GPS never gets a fix once the tablet has slept | the location provider stamps injected time with the wrong clock, and the GPS daemon restarts every 54 s | [fixes/gps](fixes/gps/) | proven after standby |
| Bluetooth never comes up, and then nothing can be paired | connman keeps it soft-blocked; the old kernel only answers a pairing once a key list has been loaded, and BlueZ loads none while nothing is paired | [fixes/bluetooth](fixes/bluetooth/) | paired from zero, audio plays, tethering works |
| The update to 4.6 seems impossible | the UI updater is a dead end on this device | [docs/update-to-4.6.0.15.md](docs/update-to-4.6.0.15.md) | done once, seven hops |

Known and not fixed yet: [docs/open-issues.md](docs/open-issues.md).

If you came here from a forum thread: [docs/forum-threads.md](docs/forum-threads.md)
lists the tablet threads on forum.sailfishos.org next to what this repository
does about each.

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

## Licence

GPL-2.0-or-later. Every script, unit and source file carries an SPDX header.
The full text is in [LICENSE](LICENSE).
