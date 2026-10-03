# Boot

Some boots come up without WiFi and without GPS. Some hang on the logo. The
next boot is fine again. Nothing was changed in between.

## Cause

The tablet's own service files contain an ordering loop:

    local-fs.target -> zram.service -> dev-zramN.swap -> swap.target
                    -> tmp.mount, mnt-obb.mount -> local-fs.target

`zram.service` wants to start after the local filesystems are mounted. The
swap devices it creates have to be ready before `swap.target`. `tmp.mount` and
`mnt-obb.mount` start after `swap.target`, and the local filesystems are only
complete once those two are mounted. No order satisfies all of that.

systemd breaks the loop on every boot by dropping one job. It does not always
drop the same one.

- It drops the zram swap jobs: the boot is fine. The four `dev-zram0..3.swap`
  units show as failed and the tablet runs without swap.
- It drops `tmp.mount` and `swap.target`: the Android side (`droid-hal-init`)
  never starts. No WiFi, no GPS.

Two boots three minutes apart, with identical configuration, gave one of each.

## Fix

Correct the one unit that closes the loop. The stock `zram.service` is ordered
after the local filesystems, and it has no reason to be: all it does is write
a size into `/sys/block/zramN/disksize` and run `mkswap`. The replacement unit
is ordered before the swap devices and after nothing.

    devel-su sh install.sh

Then reboot. The loop is gone, and the tablet gets what the units were meant
to provide in the first place: four compressed swap devices, together 20 % of
the memory, about 390 MB.

## Check that it worked

After a boot, as root:

    systemctl --failed
    systemctl is-active droid-hal-init
    cat /proc/swaps

The first must list nothing, the second must say `active`, the third must list
`/dev/zram0` to `/dev/zram3`.

To see the loop itself on a tablet without the fix, read the journal within
the first seconds of a boot:

    journalctl -b | grep "ordering cycle"

A minute later those lines are gone. The journal holds one megabyte.

## Remove

    devel-su sh uninstall.sh

## Not proven

Whether this loop is the reason for the tablet's old habit of hanging on the
logo is suspected, not proven.
