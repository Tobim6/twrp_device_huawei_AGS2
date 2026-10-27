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
* `TW_NO_SCREEN_BLANK := true`: without it the blank timer calls FBIOBLANK, the Huawei driver powers the LCD *and the touch controller* down and
  a touch can never wake the screen again. With it only the backlight drops and any touch/key (except power) wakes it.
* SELinux (`sepolicy/twrp_ags2.te`, wired with `BOARD_SEPOLICY_DIRS`): TWRP's own policy makes recovery/init/adbd/logd/ueventd permissive; the rules
  here cover the stock recovery_vendor domains (tee, hal_keymaster_default, vendor_init -- the Huawei bootloader unpacks recovery_vendor into the same
  initramfs, so their binaries are rootfs files) and what TWRP touches (backlight/vibrator sysfs, block ioctls, /data, dmesg). Booting with
  `setenforce 1` produces no denials. Android's neverallow rules reject a blanket `property_type` read grant; do not add one.
  Quick policy loop: `mka sepolicy.recovery`, push `recovery/root/sepolicy`, `load_policy` on the device, `setenforce 1`, read `dmesg | grep avc`.
* The stock teecd/keymaster services cannot link against this Android 12 userspace (they respawn every 5 s); the rc stops them.


## v10-v12 notes
- Touch: `huawei,ts_kit` registers `/dev/input/event3` in the same second as recovery's `ev_init()`, and recovery only rescans `/dev/input`
  when the directory mtime grows, so it never opened the touchscreen (no touch at all, so no wake). `twrp_input_rescan.sh` touches a temp
  file in `/dev/input` once event3 exists.
- `teecd` and `keymaster-3-0` are defined in `init.recovery.hi6250.rc` (the stock recovery_vendor rc only `start`s them) and kept running for
  later /data decryption. They need `libc_secshared`, `libkeymaster1`, `libsoftkeymasterdevice`, `libkeymaster_messages` (stock) and an
  A12-built `android.hardware.keymaster@3.0` (A9's needs libhwbinder), all shipped in `recovery/root/system/lib64`.
- SELinux: with `setenforce 1` the only remaining denials come from ad-hoc `ps`/`dmesg` shells.
