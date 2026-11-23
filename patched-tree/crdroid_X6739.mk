#
# crDroid product for Infinix GT 10 Pro (X6739)
#
# Mirrors lineage_X6739.mk from the device tree, but inherits crDroid's common
# config instead of vendor/lineage (which does not exist in a crDroid tree).
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from X6739 device
$(call inherit-product, device/infinix/X6739/device.mk)

# Inherit common crDroid stuff.
$(call inherit-product, vendor/crdroid/config/common_full_phone.mk)

BOARD_VENDOR := Infinix
PRODUCT_NAME := crdroid_X6739
PRODUCT_DEVICE := X6739
PRODUCT_MANUFACTURER := INFINIX
PRODUCT_BRAND := Infinix
PRODUCT_MODEL := Infinix X6739

PRODUCT_GMS_CLIENTID_BASE := android-transsion
PRODUCT_SYSTEM_NAME := X6739-GL
PRODUCT_SYSTEM_DEVICE := Infinix-X6739

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="vnd_x6739u_h931-user 12 SP1A.210812.016 820402 release-keys" \
    BuildFingerprint=Infinix/X6739-GL/Infinix-X6739:14/UP1A.231005.007/250610V824:user/release-keys \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)

# crDroid release type
CRDRDOID_BUILD_TYPE ?= UNOFFICIAL
