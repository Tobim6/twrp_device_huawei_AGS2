# TWRP 3.7.1 (twrp-12.1) device tree - Huawei MediaPad T5 (AGS2, hi6250)

Build: `repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1`, sync, put this
repo at `device/huawei/AGS2`, then `lunch twrp_AGS2-eng && mka recoveryimage` (`ALLOW_MISSING_DEPENDENCIES=true`). Delete
`out/target/product/AGS2/recovery/root` and `ramdisk-recovery.img` before rebuilding after tree changes (the build does not track them).

The recovery ramdisk lives in its own partition (`recovery_ramdisk`, mmcblk0p32) and borrows the kernel partition (mmcblk0p30).
`prebuilt/Image.gz-dtb` only makes a bootable `recovery.img`; to flash, wrap `ramdisk-recovery.img` in a kernel-less boot header with
`scripts/pack_recovery_ramdisk.sh` (needs a known-good p32 dump for the header) and write that to p32.

Things that were needed to make it work on this hardware (all in `recovery/root`):
* `/etc -> /system/etc` link (TWRP reads /etc/twrp.fstab; an empty etc/ dir kills partition handling).
* `init.recovery.hi6250.rc`: USB configfs gadget with UDC `hisi-usb-otg` (NOT ff100000.dwc3), `/dev/block/bootdevice` symlink.
* `/by-name -> /dev/block/bootdevice/by-name`: the device-tree fstab lists partitions as `/by-name/<x>`; without the link neither init
  nor recovery can open /misc, the stale `boot-recovery` BCB is never cleared and this bootloader then boots recovery over any reboot reason.
* Services need a `seclabel` (Android 12 init refuses to start them otherwise).
* `recovery.fstab` (Android format, for libfs_mgr) and `system/etc/twrp.fstab` (TWRP format).
No crypto stack is built (the LineageOS install on this tablet is not encrypted).
