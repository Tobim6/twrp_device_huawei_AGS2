# TWRP 3.7.1 (twrp-12.1) device tree - Huawei MediaPad T5 (AGS2, hi6250)

Build: `repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1`, sync, put this
repo at `device/huawei/AGS2`, then `lunch twrp_AGS2-eng && mka recoveryimage` (`ALLOW_MISSING_DEPENDENCIES=true`).

The recovery ramdisk of this device lives in its own partition (`recovery_ramdisk`, mmcblk0p32) and borrows the kernel
partition (mmcblk0p30). `prebuilt/Image.gz-dtb` is only used to make a bootable `recovery.img`; to flash, wrap the built
`ramdisk-recovery.img` in a kernel-less boot header with `scripts/pack_recovery_ramdisk.sh` and write that to p32.

No crypto stack is built (the LineageOS install on this tablet is not encrypted).
