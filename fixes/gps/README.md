# GPS

GPS works after a fresh boot and never again once the tablet has slept.

## Cause

The location provider (`geoclue-hybris`) gives the GPS daemon the current time
when a session starts. It has to say how old that time is, and for that it uses
the clock `CLOCK_MONOTONIC`. That clock stops while the tablet sleeps. The GPS
daemon expects a clock that keeps running through sleep.

So after any sleep the time handed to the GPS engine is wrong by the total time
the tablet has slept since boot. On the test tablet that was 12.5 hours. About
22 seconds into each session, with satellites already tracked, the engine
notices the contradiction and stops:

    Abnormal GlEngine stop. Initial time estimate was bad#ERR4

Android's init restarts the daemon. This repeats every 54 seconds, forever.

## Fix

A tiny library is loaded into the location provider. When the provider asks for
`CLOCK_MONOTONIC`, the library answers with `CLOCK_BOOTTIME`, the clock that
keeps running through sleep. Only the provider's own code gets that answer; Qt
keeps the real clock for its timers.

Proven on the test tablet: a fix after more than ten minutes of standby, which
is exactly the case that used to loop.

## Install

    devel-su sh install.sh

No reboot is needed. The installer puts the library in `/usr/lib`, adds a
drop-in for the provider's user service, and stops a running provider so the
next start loads the library.

The library has to carry the setuid bit and be owned by root. `geoclue-hybris`
is itself setuid root, and in that mode the loader refuses to preload anything
else. The bit does not make the library a program.

## Check that it worked

Open a maps app, then as root:

    grep boottime /proc/$(pidof geoclue-hybris)/maps

It must list `libgeoclue-boottime.so`. Then let the tablet sleep for ten
minutes, wake it, and ask for a position again. Without the fix that never
gives a position. Android's own log shows the difference:

    /usr/libexec/droid-hybris/system/bin/logcat -d -b main -b radio -b system | grep GlEngine

The GPS daemon logs to the radio buffer. Without `-b radio` the search is
empty whether the daemon fails or not.

## Remove

    devel-su sh uninstall.sh

## Files

- `geoclue-boottime.c`: the library, about 90 lines. It links no libc and makes the
  system call itself, so it builds on any x86 computer.
- `build.sh`: builds it with `gcc -m32`.
- `libgeoclue-boottime.so`: the build that runs on the test tablet, made with
  GCC 16.2.1. Another compiler version gives a different file from the same
  source. Build your own if you prefer.

## Good to know

- Every start is a cold start. The assistance data service this GPS chip used
  (`gllto.glpals.com`) no longer exists. Expect minutes to the first fix.
- The daemon spends its first 31 seconds looking for a modem manager the tablet
  does not have. That is harmless and costs half a minute per start.
- Reception is good: up to 42 dB-Hz indoors through a window.
- Pure Maps from Chum is a good app to test with.
