#!/system/bin/sh
# huawei,ts_kit registers /dev/input/event3 in the same second as recovery's ev_init(), and recovery only rescans /dev/input when its
# st_mtime (1 s resolution) grows, so it never opens the touchscreen. Once the node exists, bump the directory mtime so it rescans.
i=0
while [ ! -e /dev/input/event3 ] && [ $i -lt 100 ]; do
    sleep 0.2
    i=$((i+1))
done
sleep 3
: > /dev/input/.rescan
rm /dev/input/.rescan
