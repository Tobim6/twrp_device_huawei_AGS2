# Huawei MediaPad T5 (AGS2 / Dallas, hi6250 Kirin 659) - TWRP board config
# Values mirror the working prague (same SoC) TWRP 3.5.2_9 build that already runs on this hardware.
DEVICE_PATH := device/huawei/AGS2

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

# Platform
TARGET_BOARD_PLATFORM := hi6250
TARGET_BOOTLOADER_BOARD_NAME := hi6250
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := false

# Kernel: the EMUI8-based 4.4.23 kernel built from kernel_huawei_AGS2 (prebuilt, never rebuilt here)
BOARD_KERNEL_CMDLINE :=
BOARD_KERNEL_BASE := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_SECOND_OFFSET := 0x00f00000
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_MKBOOTIMG_ARGS := --kernel_offset $(BOARD_KERNEL_OFFSET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --second_offset $(BOARD_SECOND_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --os_version 9.0.0 --os_patch_level 2019-10 --header_version 0
BOARD_BOOT_HEADER_VERSION := 0
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb

# Partitions (the recovery ramdisk lives in its own partition, recovery_ramdisk, and borrows the kernel partition)
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2684354560
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912
BOARD_USERDATAIMAGE_PARTITION_SIZE := 9231597568
BOARD_CACHEIMAGE_PARTITION_SIZE := 134217728
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"

# Treble: userspace is Treble-enabled but the recovery image does not carry a vendor/system split
BOARD_AVB_ENABLE := false
BOARD_BUILD_SYSTEM_ROOT_IMAGE := false

# TWRP
TW_THEME := landscape_hdpi
TW_ROTATION := 90
TW_DEVICE_VERSION := 1-AGS2
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd_backlight0/brightness"
TW_MAX_BRIGHTNESS := 10000
TW_DEFAULT_BRIGHTNESS := 2048
TW_USE_TOOLBOX := true
TW_EXTRA_LANGUAGES := true
TW_INCLUDE_NTFS_3G := true
TW_INCLUDE_FUSE_EXFAT := true
TW_NO_USB_STORAGE := true
TW_HAS_DOWNLOAD_MODE := false
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_SCREEN_BLANK_ON_BOOT := true
# Do not power the panel down (FBIOBLANK): on this tablet that also suspends the touch controller, so a touch could never wake
# the screen again. With this flag the blank timer only drops the backlight and any touch/key (except power) wakes it.
TW_NO_SCREEN_BLANK := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_EXCLUDE_SUPERSU := true
TW_USE_NEW_MINADBD := true
# /data is not encrypted on this install (FBE/FDE are disabled), so no crypto stack is built.

# SELinux: extra rules for the recovery policy (the recovery boots enforcing on a stock kernel)
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy


# Decryption of the ROM's FBE /data (fstab.hi6250 fileencryption=aes-256-xts:aes-256-cts, keys wrapped by the Huawei keymaster 3.0 HAL)
ifneq ($(AGS2_NO_CRYPTO),true)
TW_INCLUDE_CRYPTO := true
endif

# Linux 4.4 f2fs panics (f2fs_write_cache_pages) on a /data formatted with -O project_quota,extra_attr, which TWRP adds when formatting
TW_F2FS_NO_EXTRA_FEATURES := true
