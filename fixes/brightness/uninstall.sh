#!/bin/sh
# Remove the Jolla Tablet brightness fix. Run as root:  devel-su sh uninstall.sh
cd "$(dirname "$0")" && . ../../lib/common.sh
need_root
systemctl disable tablet-backlight.service >/dev/null 2>&1
rm -f /usr/local/bin/tablet-backlight-helper /usr/local/bin/tablet-backlight-mount \
      /etc/systemd/system/tablet-backlight.service /etc/tablet-backlight.conf
systemctl daemon-reload
dbus-send --system --print-reply --dest=com.nokia.mce /com/nokia/mce/request \
    com.nokia.mce.request.set_config objpath:/system/osso/dsm/display/als_autobrightness variant:boolean:true >/dev/null 2>&1
echo "Removed, automatic brightness is on again. Reboot to get the stock behaviour back."
