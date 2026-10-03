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

Take the zram units out of the boot. They never produced working swap anyway:
on a good boot their jobs were the ones dropped.

    devel-su sh install.sh

Then reboot.

## Check that it worked

After a boot, as root:

    systemctl --failed
    systemctl is-active droid-hal-init

The first must list nothing, the second must say `active`.

To see the loop itself on a tablet without the fix, read the journal within
the first seconds of a boot:

    journalctl -b | grep "ordering cycle"

A minute later those lines are gone. The journal holds one megabyte.

## Remove

    devel-su sh uninstall.sh

## Not done

The proper fix is to correct `zram.service` so that it does not wait for the
local filesystems. That would also give the tablet working compressed swap,
which 2 GB of memory could use. It changes more than this does, and it has not
been tried.

Whether this loop is the reason for the tablet's old habit of hanging on the
logo is suspected, not proven.
