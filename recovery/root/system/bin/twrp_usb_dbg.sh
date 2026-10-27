#!/system/bin/sh
# Dump the USB gadget state into the kernel log (ends up in the ramoops console).
{
echo "twrpdbg: --- usb state $(date)"
echo "twrpdbg: configs=$(ls /config/usb_gadget/g1/configs/b.1 2>&1 | tr '\n' ' ')"
echo "twrpdbg: functions=$(ls /config/usb_gadget/g1/functions 2>&1 | tr '\n' ' ')"
echo "twrpdbg: UDC=$(cat /config/usb_gadget/g1/UDC 2>&1)"
echo "twrpdbg: /sys/class/udc=$(ls /sys/class/udc 2>&1 | tr '\n' ' ')"
echo "twrpdbg: port_mode=$(cat /sys/devices/virtual/android_usb/android0/port_mode 2>&1)"
echo "twrpdbg: usb-ffs/adb=$(ls /dev/usb-ffs/adb 2>&1 | tr '\n' ' ')"
echo "twrpdbg: props config=$(getprop sys.usb.config) state=$(getprop sys.usb.state) ffs=$(getprop sys.usb.ffs.ready) ctrl=$(getprop sys.usb.controller) configfs=$(getprop sys.usb.configfs)"
} > /dev/kmsg 2>&1
