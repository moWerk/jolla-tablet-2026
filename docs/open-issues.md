# Open issues

Things that are known and not fixed. Each entry says what is measured and what
is only suspected.

## Automatic brightness

The brightness fix switches automatic adjustment off, because its table
assumes the stock range. The light sensor responds, so an automatic mode for
the new range is possible. Not written.

## Bluetooth is audio output only

Music plays over A2DP, and headset buttons control the Media app. The headset
profile for calls shows as not available.

## One WiFi failure is unexplained

Once, after WiFi had been off overnight, it would not reconnect, and toggling
did not help. A reboot cured it and erased the log. It has not happened again.

## The log is too small to diagnose anything

The journal lives in memory and holds one megabyte. The kernel fills most of
it with storage and camera chatter marked as errors. Lines from the first
seconds of a boot are gone a minute later.

## The Media app cannot open files outside the user folders

Not a fault, but it looks like one. The Media app runs in a sandbox that sees
Music, Documents, Downloads and the other standard folders. A file placed in
the top of the home directory is listed, because the indexer runs outside the
sandbox, and then does not play. The log says `Resource not found`. Put music
into `~/Music`.

## Screenshots are empty

Screenshots come out fully transparent. The home screen draws through the
hardware composer and cannot read the picture back. This looks like a missing
capability, not a bug.

## GPS has no assistance data

The service that supplied orbit predictions for this chip no longer exists.
Every start is a cold start.

## Battery kept at 100 %

A tablet that lives on a charger keeps an old cell full and warm. That is how
packs swell. `harbour-battery-charging-control` from Chum can limit the charge.
No limit has been chosen or tested here.
