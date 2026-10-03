# Brightness

The stock tablet is too bright at its lowest setting, and the slider changes
little. That makes it unpleasant in a dark room and useless in a car at night.
The panel can do far more than the software lets it.

## Cause

There are two layers, and both squeeze the range.

**The kernel.** The backlight is driven by a PWM signal. The display driver
accepts brightness values from 0 to 255, but it does not pass them through. It
maps them onto a fixed band of the PWM duty cycle, from about 20 % to about
64 %. Value 0 is still a 20 % duty cycle. That is the "lowest" you can ever
reach from the settings.

**mce.** With automatic brightness on, the slider does not set a level. It
selects a row in a table and the ambient light picks the column. In room light
the whole slider then spans only values 22 to 119 of 255.

Together: the slider moves the backlight between about 23 % and 40 % duty.

## Fix

The driver's band cannot be changed without rebuilding the kernel. So the
driver is taken out of the path.

Before mce starts, a plain file is mounted over the backlight's `brightness`
attribute. mce writes its value into that file. A small helper watches the file
and programs the PWM controller directly, through a debug attribute the PWM
driver offers (`test_write`). The helper uses its own curve, from barely
visible up to the driver's own maximum.

Automatic brightness keeps working and gains the same range. mce's ambient
light table feeds the new curve unchanged.

**DPST is switched off too.** The tablet runs an Intel daemon from the Android
side, `coreu`. It does DPST, a content-adaptive backlight: whenever the picture
changes, it makes the display driver set the backlight again, in a burst of ten
steps 50 ms apart. Each of those steps puts the backlight back at the driver's
own level. With the wider range that shows as the brightness jumping up ten
times on every touch. A kernel function trace showed all of those writes coming
from `coreu`. The helper stops `coreu` through Android's init and keeps it
stopped. Set `stop_dpst=0` in the config to leave it running.

| slider | before (duty) | after (duty) |
|---|---|---|
| lowest | 23 % | about 0.4 % |
| 25 % | not measured | 3 % |
| 50 % | 30 % | 14 % |
| 75 % | 34 % | 34 % |
| highest | 40 % | 64 % |

The "before" column is the stock tablet with automatic brightness on, in room
light. The "after" column is with automatic brightness off, where the slider
sets the level directly. Both are read from the PWM register, not estimated.

## Automatic brightness

Recorded with the slider at 62 of 100, reading the light sensor next to what
the backlight was set to:

| light at the sensor | sensor reading | PWM duty |
|---|---|---|
| covered | 0 | darkest |
| evening room | 3 to 5 | about 1 % |
| brighter spot in the room | 22 to 27 | about 7 % |
| flashlight | 900 to 6500 | 64 % |

The slider shifts the whole response up or down. Judged by eye in evening
light and with a flashlight. Not yet judged in daylight.

## What the backlight costs

Measured on battery with the home screen showing, WiFi on, 15 samples per
level. The fuel gauge reports in 16 mA steps, so read these as rough figures.
Runtime is the measured battery capacity (4375 mAh) divided by the current.

| state | PWM duty | current | runtime |
|---|---|---|---|
| screen off, tablet awake | | 193 mA | |
| slider at 1 | 0.4 % | 509 mA | 8.6 h |
| slider at 25 | 3 % | 510 mA | 8.6 h |
| slider at 50 | 14 % | 558 mA | 7.8 h |
| slider at 62, the old lowest | 21 % | 596 mA | 7.3 h |
| slider at 81, the old highest in room light | 39 % | 674 mA | 6.5 h |
| slider at 100 | 64 % | 790 mA | 5.5 h |

Switching the screen on costs about 315 mA before the backlight adds anything.
The backlight then costs about 4.4 mA per percent of duty, up to 280 mA at the
top. Against the old lowest setting the new low end saves about 90 mA, which is
1.3 hours more with the screen on.

## Install

    devel-su sh install.sh

Then reboot. The low end is now very dark. If the screen looks switched off in
daylight, it is not: raise the slider.

## Tune it

`/etc/tablet-backlight.conf`:

    floor=0xff      # the lowest slider position. 0xff is the darkest.
    ceiling=0x5d    # the highest. 0x5d is the kernel driver's own maximum.
    gamma=2.2       # the curve in between. 1.0 is linear.
    stop_dpst=1     # stop the coreu daemon. 0 leaves it running.

After a change: `devel-su systemctl reload tablet-backlight`

`ceiling` is deliberately left at the driver's maximum. A smaller number drives
the backlight harder than the manufacturer allowed. That means more heat in a
fanless tablet. It has not been tried.

## Check that it worked

As root:

    systemctl status tablet-backlight
    cat /sys/bus/platform/devices/80860F09:00/ctl_reg

The last two digits of the register are the PWM on-time divisor: `ff` is the
darkest, `5d` the brightest. Move the slider and read it again.

## Remove

    devel-su sh uninstall.sh

Then reboot.

## Limits

- The driver puts the backlight at its own minimum for a moment each time the
  screen wakes, before the helper sets the real value. On the test tablet that
  is not visible.
- The fix relies on a debug attribute of the PWM driver. It is not an intended
  interface. It exists on the tablet's 3.10 kernel.
- The helper is a Python script and uses about 8 MB of memory.
- If the helper is not running, the screen stays at the driver's minimum, which
  is the old lowest setting. The tablet stays usable.
- With `coreu` stopped there is no DPST. On the stock range DPST lowers the
  backlight for dark pictures; what that saved has not been measured. `coreu`
  also offers an HDCP interface, which nothing on Sailfish OS uses.
