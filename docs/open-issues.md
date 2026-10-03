# Open issues

Things that are known and not fixed. Each entry says what is measured and what
is only suspected.

## The boot is a coin toss

**Measured.** The tablet's own service files contain an ordering loop:

    local-fs.target -> zram.service -> dev-zramN.swap -> swap.target
                    -> tmp.mount, mnt-obb.mount -> local-fs.target

`zram.service` wants to start after the local filesystems. The swap devices it
creates have to be ready before `swap.target`. `tmp.mount` and `mnt-obb.mount`
start after `swap.target` and before the local filesystems are complete. No
order satisfies all of that. systemd breaks the loop on every boot by dropping
one job, and it does not always drop the same one.

- When it drops the zram swap jobs, the boot is fine. The four
  `dev-zram0..3.swap` units show as failed and the tablet has no swap.
- When it drops `tmp.mount` and `swap.target`, the Android side
  (`droid-hal-init`) does not start. There is no WiFi and no GPS on that boot.

Two boots with identical configuration, three minutes apart, gave one of each.

**Suspected.** This is the reason for the tablet's old habit of hanging on the
logo every other boot. Not proven.

**Not fixed yet.** The loop has to be removed, either by taking the zram units
out of the boot or by correcting `zram.service`. Until then: if a boot comes up
without WiFi, reboot once more.

## No swap

A consequence of the above. The tablet has 2 GB of memory and runs without any
swap.

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
