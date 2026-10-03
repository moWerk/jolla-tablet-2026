# Open issues

Things that are known and not fixed. Each entry says what is measured and what
is only suspected.

## No swap

The tablet has 2 GB of memory and runs without any swap. Its zram swap units
never worked: they sit in an ordering loop, see [fixes/boot](../fixes/boot/).
That fix removes the loop by masking them. Correcting `zram.service` instead
would give the tablet working compressed swap. Not tried.

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
