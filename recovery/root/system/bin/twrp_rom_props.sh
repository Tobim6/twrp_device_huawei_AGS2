#!/system/bin/sh
# The keymaster 3.0 key blobs that protect the ROM's /data were created with the ROM's OS version / patch level, and (soft) keymaster refuses a
# blob that is newer than the configuration it is given. This recovery's own props (/vendor/default.prop of the stock recovery_vendor, Android
# 8.0.0 / 2020-08-01) are older, so copy the ROM's values before the keymaster HAL / keystore2 are used, and restart the HAL so it re-reads them.
SYS=/dev/block/bootdevice/by-name/system
VEN=/dev/block/bootdevice/by-name/vendor
M=/mnt/rom_props

i=0
while [ ! -e $SYS ] && [ $i -lt 100 ]; do sleep 0.2; i=$((i+1)); done
[ -e $SYS ] || exit 0

get() { sed -n "s/^$2=//p" "$1" | head -n 1; }

mkdir -p $M
if mount -o ro $SYS $M 2>/dev/null; then
    f=$M/build.prop
    [ -f $f ] || f=$M/system/build.prop
    rel=$(get $f ro.build.version.release)
    spl=$(get $f ro.build.version.security_patch)
    umount $M
fi
vspl=
if [ -e $VEN ] && mount -o ro $VEN $M 2>/dev/null; then
    vspl=$(get $M/build.prop ro.vendor.build.security_patch)
    umount $M
fi

[ -n "$rel" ] && resetprop ro.build.version.release "$rel"
[ -n "$spl" ] && resetprop ro.build.version.security_patch "$spl"
[ -n "$vspl" ] && resetprop ro.vendor.build.security_patch "$vspl"
[ -z "$vspl" ] && [ -n "$spl" ] && resetprop ro.vendor.build.security_patch "$spl"
echo "twrp_rom_props: release=$rel patch=$spl vendor_patch=$vspl" > /dev/kmsg
# the HAL read its configuration when init started it in early-init
stop keymaster-3-0
start keymaster-3-0
