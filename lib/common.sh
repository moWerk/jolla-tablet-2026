# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Shared checks for the install scripts. Sourced, not run.
# Every installer stops early with a plain message instead of half-installing.

die() { echo "STOP: $*" >&2; exit 1; }

need_root() {
    [ "$(id -u)" = 0 ] || die "this must run as root. Type: devel-su sh $0"
}

need_tablet() {
    grep -q '^MER_HA_DEVICE=tbj' /etc/hw-release 2>/dev/null \
        || die "this is not a Jolla Tablet (MER_HA_DEVICE is not tbj). Nothing was changed."
    ver=$(sed -n 's/^VERSION_ID=//p' /etc/os-release)
    [ "$ver" = 4.6.0.15 ] || echo "NOTE: tested on Sailfish OS 4.6.0.15 only. This tablet runs $ver."
}

# The user who owns the home directory: nemo on a tablet updated from old
# releases, defaultuser on a fresh install.
main_user() {
    for u in nemo defaultuser; do [ -d /home/$u ] && { echo $u; return; }; done
    die "found neither /home/nemo nor /home/defaultuser"
}
