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

## FBE decryption of the ROM's /data (v13-v21)
Enable with `TW_INCLUDE_CRYPTO` (default; `AGS2_NO_CRYPTO=true` builds without). Everything below was needed on this 4.4 kernel / A9 ROM:
- `fileencryption=aes-256-xts:aes-256-cts:v1` in the recovery fstabs: the kernel only has the legacy v1 key API (no FS_IOC_ADD_ENCRYPTION_KEY).
- `install_keyring` in the rc: vold's legacy path needs the "fscrypt" keyring in the session keyring.
- `recovery/root/system/etc/vintf/manifest.xml`: servicemanager refuses to register keystore2 without a framework manifest declaring it.
- `patches/system_security-keystore2-recovery-sid.patch`: this kernel's binder has no BINDER_FLAG_TXN_SECURITY_CTX, so keystore2 never gets a
  calling SID and fails every permission check; fall back to the recovery context.
- `twrp_rom_props.sh`: soft keymaster rejects blobs newer than its configured OS version / patch level, and the stock recovery_vendor props say
  8.0.0 / 2020-08-01; copy the ROM's values (and restart the HAL) early in boot.
- keymaster 3.0 HAL (stock vendor) + A12-built `android.hardware.keymaster@3.0`; gatekeeper HAL + `system_teecd` + libteec/libtuidaemon/libxml2.
  libteec connects to teecd and system_teecd, which authenticate the caller by uid, so the gatekeeper HAL must run as `system`.
- `/dev/tc_ns_client` labelled `tee_client_device`.
- `patches/bootable_recovery-f2fs-no-extra-features.patch` / `TW_F2FS_NO_EXTRA_FEATURES`: never format /data with extra_attr (kernel panic).
Debug aids shipped: logd, logcat, strace.
- `patches/system_vold-legacy-keystore-fallback.patch`: an Android 9 ROM keeps the locksettings key as a Keystore 1 file
  (`/data/misc/keystore/user_0/1000_USRPKEY_synthetic_password_*`); copy those files (never touch the originals) into keystore2's working dir
  as uid 0 entries and look the key up as an app key if the Android 12 style SELinux-namespace lookup misses.
Result: "User 0 Decrypted Successfully" on a ROM with FBE (fileencryption=aes-256-xts:aes-256-cts) /data.
- `patches/bootable_recovery-fbdev-bgra-no-inplace-swap.patch`: with RECOVERY_BGRA, fbdev_flip() swapped R/B in place on the persistent draw surface, so a
  page re-flipped without a full redraw (the password page) alternated between correct and swapped colours every frame. Swap while copying instead.
- Android 13 ROMs: nothing here depends on the ROM's Android version (props and filesystem type are read from the ROM, both the Android 12+
  locksettings key lookup and the Keystore 1 fallback exist). Untested: no Android 13 ROM was available. The kernel is 4.4, so such a ROM is limited to
  fscrypt v1 (no metadata encryption / v2 policies), which is what this recovery's fstab expects.
