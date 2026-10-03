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

## Files

The source of the library, its build script and the installer are being moved
into this folder. Until they are here, this page only documents the cause.

## Good to know

- Every start is a cold start. The assistance data service this GPS chip used
  (`gllto.glpals.com`) no longer exists. Expect minutes to the first fix.
- The daemon spends its first 31 seconds looking for a modem manager the tablet
  does not have. That is harmless and costs half a minute per start.
- Reception is good: up to 42 dB-Hz indoors through a window.
- Pure Maps from Chum is a good app to test with.
