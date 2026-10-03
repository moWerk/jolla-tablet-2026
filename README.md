# Jolla Tablet in 2026

The Jolla Tablet (JT-1501) still works in 2026. It runs Sailfish OS 4.6.0.15,
the last release made for it. Out of the box several things are broken or
awkward on that release. This repository holds the fixes, one folder each, with
an installer and an uninstaller.

Everything here was found and measured on one tablet. Nothing here touches the
kernel or the boot image. Every fix can be removed again.

## The headline: display brightness

**The tablet has been too bright since the day it was delivered.** The lowest
setting was still a 23 % backlight, and the whole slider only moved it between
23 % and 40 %. That is not a limit of the panel. The kernel's display driver
never lets the backlight below 20 %, and automatic brightness squeezes the
slider further. It is still like that in 4.6.0.15, the last release.

With the fix the slider runs from about 0.4 % to 64 %. The low end is barely
visible, which is what a tablet in a dark car needs. The top is brighter than
the stock tablet reached in room light. Automatic brightness keeps working over
the new range. At the low end the screen draws about 90 mA less than at the old
lowest setting, which is 1.3 hours more on a charge.

Cause, numbers and how to tune it: [fixes/brightness](fixes/brightness/).

## What is fixed

| Problem | Cause | Fix | State |
|---|---|---|---|
| **Since delivery:** the screen is too bright at the lowest setting, and the slider barely does anything | the kernel squeezes the backlight into 20 % to 64 % duty, and automatic adjustment squeezes the slider further | [fixes/brightness](fixes/brightness/) | proven by reboot |
| The brightness jumps on every touch once the range is wider | Intel's `coreu` daemon re-sets the backlight ten times on every picture change (DPST) | [fixes/brightness](fixes/brightness/) | proven by trace and by eye |
| WiFi is "on" after boot but finds no networks | connman powers WiFi while Android's `wlan_prov` still holds the chip in reset, and never retries | [fixes/wifi](fixes/wifi/) | proven by reboot |
| Saved WiFi networks ask for their password again | the adapter comes up with one of two addresses, and connman files networks under the one it sees | [fixes/wifi](fixes/wifi/) | proven by reboot |
| Some boots have no WiFi and no GPS, or hang on the logo; no swap | the tablet's own zram service is ordered into a loop, and systemd breaks it differently from boot to boot | [fixes/boot](fixes/boot/) | loop gone, swap works |
| GPS never gets a fix once the tablet has slept | the location provider stamps injected time with the wrong clock, and the GPS daemon restarts every 54 s | [fixes/gps](fixes/gps/) | proven after standby |
| Bluetooth never comes up, and then nothing can be paired | connman keeps it soft-blocked; the old kernel only answers a pairing once a key list has been loaded, and BlueZ loads none while nothing is paired | [fixes/bluetooth](fixes/bluetooth/) | paired from zero, audio plays, tethering works |
| The update to 4.6 seems impossible | the UI updater is a dead end on this device | [docs/update-to-4.6.0.15.md](docs/update-to-4.6.0.15.md) | done once, six hops |

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

Disclosure according to LLMGD.

A machine did most of this. Claude, an LLM, worked directly on the tablet over
ssh in October 2026. It found the causes, designed the fixes and wrote every
script, unit and document in this repository, including this text. moWerk set
the goals, described what the tablet did, decided what the repository should
be, and judged every result on the device by eye and ear.

Nobody has read the code. Instead every fix was installed on a real tablet,
removed again, and installed from scratch, and each one was checked after a
reboot. That was one tablet. What happens on yours is not known.

Several first versions were wrong. One of them left the tablet hanging on the
logo, another one made the display flicker. They were caught, by a test or by
using the tablet. Assume there are faults nobody has hit yet. Every fix has an
uninstaller for that reason. The list of what went wrong is in the verdict.

LLMGD grades two things. Origin says who made it, from O0 (the machine decided
and wrote) to O4 (no machine involved). Assurance says how well a human
governed it, from A0 to A5.

The result is **LLMGD-3, origin O0**. A3 means understood and tested, but not
read. O0 means the machine decided design and wording from goals a human gave.
About a third of the work followed a design the human named. The grade is
provisional: the GPS library, the WiFi kick script and the update path come
from an earlier session whose record was not at hand for grading.

This is a self-assessment. The same model built the work and graded it. That is
a conflict of interest, and an independent re-grade is welcome. The full
verdict with its evidence: [docs/LLMGD.md](docs/LLMGD.md).

<table>
<tr>
<td align="center"><a href="docs/LLMGD.md"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/moWerk/llmgd-specs/main/assets/llmgd-signal-lockup-3-dark.svg"><img src="https://raw.githubusercontent.com/moWerk/llmgd-specs/main/assets/llmgd-signal-lockup-3.svg" height="72" alt="LLMGD-3"></picture></a><br><sub>Assurance A3: understood and tested, not read</sub></td>
<td align="center"><a href="docs/LLMGD.md"><img src="https://raw.githubusercontent.com/moWerk/llmgd-specs/main/assets/llmgd-signal-o0.svg" height="72" alt="origin O0"></a><br><sub>Origin O0: machine-designed and machine-written</sub></td>
</tr>
</table>

<sub>LLMGD is an open standard: <a href="https://github.com/moWerk/llmgd-specs">moWerk/llmgd-specs</a>. Machine-readable:<br>
<code>Disclosure: LLMGD-3 · origin O0 (machine-designed and machine-written; human-understood and device-tested on one tablet; code unread; provisional)</code><br>
<code>LLMGD: v0.2; assurance=A3; flags=U,T; origin={O0:.65,O1:.35}; origin_headline=O0; scope=fixes+docs; graded-by=claude-fable-5-1; retrieval=author-side</code></sub>

## Licence

GPL-2.0-or-later. Every script, unit and source file carries an SPDX header.
The full text is in [LICENSE](LICENSE).
