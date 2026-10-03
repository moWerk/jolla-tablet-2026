# Updating to Sailfish OS 4.6.0.15

4.6.0.15 is the last release for the Jolla Tablet. Jolla's own device table
says 3.4.0. That is wrong: the releases page says 4.6.0.15, and the tablet gets
there. Sailfish OS 5.0 dropped the device.

The update dialog in Settings is a dead end on this tablet. The command line
works. The test tablet went from 4.0.1.48 to 4.6.0.15 in one evening.

This page is the short version. It was done once, on one tablet.

## The path

You cannot jump. Every stop release has to be installed in order:

    4.0.1.48 -> 4.1.0.24 -> 4.2.0.21 -> 4.3.0.15 -> 4.4.0.72 -> 4.5.0.25 -> 4.6.0.15

## One hop

As root (`devel-su`), once:

    pkcon install zypper

The package library is already on the tablet. Only the command line tool is
missing.

Then for each hop:

    ssu re 4.1.0.24        # the next stop release
    ssu ur
    zypper ref
    zypper dup
    reboot

`zypper dup` takes tens of minutes. Reboot after every hop, whatever zypper
says.

## Traps

**1. zypper says no reboot is needed. It is wrong.** After the update the
system services run on deleted files, and the Android part cannot restart
live. Always reboot.

**2. "Remove these packages first" is not always right.** The update check
names packages to remove. Sometimes that is correct and sometimes it breaks
the tablet. On 4.4 it named `gmp-droid` and `gstreamer1.0-droid`. Forcing
those out tears out the hardware adaptation. The rule: ask
`pkcon resolve <package>`. If a newer version is available, leave it alone,
the update replaces it. If there is none and nothing needs the package,
remove it.

**3. "Store credentials not received" near the end.** The update replaces the
store client while it runs. After that, downloads from the store repository
fail. Answer `i` (ignore). Never `a` (abort).

**4. `zypper verify` offers to uninstall a "product".** After everything
succeeded it offers to remove a product named after a comment line in
`/etc/hw-release`. Answer `a` (abort). This is the most dangerous prompt of
the whole path.

**5. Jolla asks for 3 to 4 GB of free space.** The tablet's system partition
is 2.3 GB in total. The update works anyway, and it frees space.

**6. A logo that stays forever is usually not a hang.** If the backlight dims
and brightens when you press the power button, the system is up and only the
home screen is missing. Force one reboot: hold Volume Down and Power for more
than 10 seconds. See [fixes/boot](../fixes/boot/) for the suspected cause.

## Recovery menu

Power off. Hold Volume Down and Power until the logo appears. Choose Recovery
with the volume keys and confirm with Power. Connect USB, then
`telnet 10.42.66.66` from a computer.

- **Never choose option 1 (factory reset).** It reflashes 1.1.9.
- Avoid option 4 (filesystem check). It runs a 2015 tool against a filesystem
  written by modern ones.
