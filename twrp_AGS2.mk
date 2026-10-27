# Huawei MediaPad T5 (AGS2, hi6250) - TWRP
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, vendor/twrp/config/common.mk)

PRODUCT_DEVICE := AGS2
PRODUCT_NAME := twrp_AGS2
PRODUCT_BRAND := HUAWEI
PRODUCT_MODEL := MediaPad T5
PRODUCT_MANUFACTURER := HUAWEI
