# Huawei MediaPad T5 (AGS2, hi6250) - TWRP
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, vendor/twrp/config/common.mk)

PRODUCT_DEVICE := AGS2
PRODUCT_NAME := twrp_AGS2
PRODUCT_BRAND := HUAWEI
PRODUCT_MODEL := MediaPad T5
PRODUCT_MANUFACTURER := HUAWEI

# Stock teecd / keymaster 3.0 HAL (from recovery_vendor) were built for the A9 userspace. recovery/root/system/lib64 carries what they
# link and this ramdisk lacks: libc_secshared, libkeymaster1, libsoftkeymasterdevice, libkeymaster_messages (stock, self-contained) and
# android.hardware.keymaster@3.0 (built from hardware/interfaces in this tree; A9's copy needs libhwbinder, which A12 no longer has).

# Debug aids shipped in the ramdisk (small): logd/logcat (the stock rc already defines and starts logd) and strace. TWRP's vold/keystore code
# only reports its errors through liblog, so without logd decryption failures are invisible.
