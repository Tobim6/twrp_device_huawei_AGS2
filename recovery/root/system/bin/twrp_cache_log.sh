#!/system/bin/sh
# Boot diagnostics: mirror the recovery's early state into /cache/twrp_log so a hung or USB-less boot can be
# inspected afterwards from another recovery (read /cache/twrp_log/* there).
echo "twrp_cache_log: started" > /dev/kmsg 2>/dev/null
i=0
while [ ! -b /dev/block/bootdevice/by-name/cache ] && [ $i -lt 100 ]; do sleep 0.2; i=$((i+1)); done
mkdir -p /cache
mount -t ext4 -o nosuid,nodev,noatime /dev/block/bootdevice/by-name/cache /cache 2>/dev/null
D=/cache/twrp_log
mkdir -p $D
echo "started $(date) waited=$i cache_block=$([ -b /dev/block/bootdevice/by-name/cache ] && echo yes || echo no)" > $D/started.txt
sync
n=0
while true; do
  dmesg > $D/dmesg.tmp 2>&1 && mv $D/dmesg.tmp $D/dmesg.txt
  { echo "tick $n $(date)"; getprop; } > $D/props.txt 2>&1
  { ps -A 2>&1 || ps; } > $D/ps.txt 2>&1
  { mount; echo; ls -la /dev/block/bootdevice/ /dev/block/bootdevice/by-name 2>&1; } > $D/mounts.txt 2>&1
  { echo "udc:"; ls /sys/class/udc 2>&1; echo "gadget:"; ls /config/usb_gadget/g1 2>&1; echo "UDC=$(cat /config/usb_gadget/g1/UDC 2>&1)";
    echo "ffs:"; ls /dev/usb-ffs/adb 2>&1; echo "configfs prop=$(getprop sys.usb.configfs) config=$(getprop sys.usb.config) state=$(getprop sys.usb.state)"; } > $D/usb.txt 2>&1
  [ -f /tmp/recovery.log ] && cp /tmp/recovery.log $D/recovery.log 2>/dev/null
  ls -la /dev/graphics /dev/input /sys/class/graphics /sys/class/leds 2>&1 > $D/devices.txt
  sync
  n=$((n+1))
  if [ $n -lt 100 ]; then sleep 3; else sleep 30; fi
done
