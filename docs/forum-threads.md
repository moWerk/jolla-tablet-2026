# Forum threads

Problems with the Jolla Tablet that owners reported on
[forum.sailfishos.org](https://forum.sailfishos.org), and how each relates to
what is in this repository. Collected in October 2026 by searching the forum
for tablet reports.

"Likely the same fault" means the symptoms match what was measured on the test
tablet. It does not mean the fix was tried on the reporter's tablet.

## Addressed here

| Thread | Reported | Here |
|---|---|---|
| [Jolla Tablet: no wlan after update](https://forum.sailfishos.org/t/14744) (2023) | No WLAN after an update or reboot. One owner writes that the tablet "forgets the password between updates/reboots" and that it "appears to change MAC address a lot". | Likely the same faults: [fixes/wifi](../fixes/wifi/). The address does not change at random. The adapter comes up with one of two addresses, and saved networks are filed under the one connman sees. |
| [4.4.0.58 (almost) breaks tablet, doesn't get past boot logo](https://forum.sailfishos.org/t/11021) (2022 to 2024) | The tablet stays on the Jolla and Intel logo, for one owner "9 times out of 10". When it does come up, WiFi does not work. For one owner removing some Chum packages brought WiFi back. | Likely the same fault: [fixes/boot](../fixes/boot/). An ordering loop in the tablet's own units makes systemd drop a different job from boot to boot. On a bad boot the Android side never starts, which takes WiFi with it. On the test tablet the outcome changed from one boot to the next with nothing changed in between. |
| [[release notes] Koli 4.0.1](https://forum.sailfishos.org/t/4542) (2021), several posts | No WLAN after the update. The update runs with a black screen. The root partition is too small. | WLAN: [fixes/wifi](../fixes/wifi/). The rest: [update-to-4.6.0.15.md](update-to-4.6.0.15.md). |
| [Jolla tablet issue](https://forum.sailfishos.org/t/2760) (2020), [Aigo tablet bootloop after update](https://forum.sailfishos.org/t/10254) (2022), [[Release notes] Sauna 4.6.0.11](https://forum.sailfishos.org/t/17815) (2024) | The update shows a black screen and no progress. Powering off in the middle leaves a boot loop. | [update-to-4.6.0.15.md](update-to-4.6.0.15.md): update from the command line, where the progress is visible. |
| [[Tablet] Can not fully update to 4.5.0.18](https://forum.sailfishos.org/t/14959) (2023) | Packages held back, a bluez4 against bluez5 conflict. Solved in the thread. | Same family as the traps in [update-to-4.6.0.15.md](update-to-4.6.0.15.md). |
| [Updating tablet 4.4.0.68->4.4.0.72 fails](https://forum.sailfishos.org/t/13677) (2022), [How to shrink /home-partition on Jolla tablet?](https://forum.sailfishos.org/t/18219) (2024) | The root partition is too small for an update. The thread's answer is to resize it. | The test tablet went from 4.0.1.48 to 4.6.0.15 on its 2.3 GB root without resizing, see [update-to-4.6.0.15.md](update-to-4.6.0.15.md). If yours is full, the resize is the way. |
| [Jolla Tablet, deep sleep issue. Any workarounds?](https://forum.sailfishos.org/t/2257) (2020) | The battery drains with the screen off. | Not reproduced. The test tablet loses about 0.2 % per hour in standby on 4.6.0.15. One known source of load was the GPS daemon restarting every 54 seconds, which [fixes/gps](../fixes/gps/) stops. Whether that is what drained other tablets is not known. |
| Screenshots, mentioned in several threads, for example [this one](https://forum.sailfishos.org/t/14744) | Screenshots come out empty. | Not fixed. See [open-issues.md](open-issues.md). |

## Related, but a different fault

| Thread | Reported | Here |
|---|---|---|
| [[Jolla Tablet] Gps stopped working since sfos 4.3.0.15](https://forum.sailfishos.org/t/13634) (2022) | GPS dead on 4.3 and 4.4. Fixed by Jolla in 4.5.0. | A different fault. [fixes/gps](../fixes/gps/) is for 4.6.0.15, where GPS works after a boot and stops for good once the tablet has slept. |
| [Bluetooth tethering on SFOS on the receiving end](https://forum.sailfishos.org/t/18757) (2024) | Tethering over Bluetooth barely works. | Not looked at. [fixes/bluetooth](../fixes/bluetooth/) makes pairing possible, which tethering needs first. |

## Not reproduced on the test tablet

| Thread | Reported | Here |
|---|---|---|
| [Cannot play mp4 videos on Tablet](https://forum.sailfishos.org/t/5260) (2021, on 4.0.1) | Gallery says "Video could not be loaded". It plays when Gallery is started from the terminal. | On 4.6.0.15 a camera recording plays in Gallery, opened the normal way. On first start Gallery asks for its permissions; until that is accepted nothing opens. |
| [Jolla Tablet 4.6.0.13 Https Uri Handler error](https://forum.sailfishos.org/t/19922) (2024) | Streaming apps fail with `No URI handler implemented for "https"`. The thread finds the element `souphttpsrc` as root but not as the user. | Only half checked. In a plain shell `gst-inspect-1.0 souphttpsrc` finds the element as root and as the user. No streaming app was tried. |

## Not looked at

Reported by others. Nothing in this repository addresses these.

| Thread | Reported |
|---|---|
| [WLAN not found by Jolla Tablet when more than one AP broadcasts the same SSID (mesh)](https://forum.sailfishos.org/t/10412) (2022) | The network is not found in a mesh. |
| [[4.0.1.45] Extremely strange lock code bug on Jolla Tablet](https://forum.sailfishos.org/t/4808) (2021), ["Too many attempts" Permanently locked device](https://forum.sailfishos.org/t/23096) (2025) | The lock code is rejected and the tablet reports itself permanently locked. |
| [[Tablet; 4.6.0.13] Deleting the Jolla account almost breaks the tablet](https://forum.sailfishos.org/t/19277) (2024) | After deleting the account and rebooting: stuck on the logo, no WLAN. |
| [QR code recognition does not work on Jolla Tablet](https://forum.sailfishos.org/t/6486) (2021) | No QR recognition, and the exposure slider has no effect. |
| [Jolla Tablet touch screen unresponsive](https://forum.sailfishos.org/t/5467) (2021) | One report. Hardware suspected. |
| [Jolla Tablet: Charging Issue](https://forum.sailfishos.org/t/21372) (2024) | Shows charging while discharging. The thread points at the USB socket and the cable. |
| [Certificate issues with Android apps on old AlienDalvik](https://forum.sailfishos.org/t/19645) (2024), [Android SDK too old for F-Droid](https://forum.sailfishos.org/t/23680) (2025), [Android won't install anymore after resetting of my Jolla tablet](https://forum.sailfishos.org/t/4111) (2020) | The Android layer on the tablet is Android 4.4. |
| [My jolla tablet can't work, I need help](https://forum.sailfishos.org/t/6605) (2021), [Search working Jolla Tablet coremodul](https://forum.sailfishos.org/t/10378) (2022) | Recovery mode and factory reset trouble. |
| [[Jolla Tablet] short tap on links in email content did not open SailfishOS Browser](https://forum.sailfishos.org/t/8682) (2021) | Links in email do not open. |

## Useful, not a fault

- [Changing the battery on the Jolla Tablet](https://forum.sailfishos.org/t/14592) (2023): how to open the tablet and replace the cell.
