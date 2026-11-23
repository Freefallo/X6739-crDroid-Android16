# crDroid 12 (Android 16) — Infinix GT 10 Pro (X6739)

**Unofficial** build. crDroid has no official Infinix support, so this repo pins
community device trees and builds crDroid's `16.0` manifest (`lineage-23.2`
generation) on GitHub Actions.

## What this is

| | |
|---|---|
| Device | Infinix GT 10 Pro 5G (`X6739`) |
| SoC | MediaTek MT6893 / Dimensity 8050 |
| ROM | crDroid 12 (Android 16) |
| Source | `crdroidandroid/android` branch `16.0` |
| Flavor | vanilla (no GApps) — flash a GApps package separately if you want them |
| Output | `crDroidAndroid-16.0-<date>-X6739-v<ver>.zip` |

## Trees used

Everything is pulled by `local_manifests/X6739.xml`:

| Path | Repo | Branch |
|---|---|---|
| `device/infinix/X6739` | vlxlxlv/android_device_infinix_X6739 | lineage-23.2 |
| `device/infinix/X6739-kernel` | vlxlxlv/android_device_infinix_X6739-kernel | lineage-22.2 (prebuilt kernel) |
| `vendor/infinix/X6739` | vlxlxlv/android_vendor_infinix_X6739 | lineage-23.2 |
| `hardware/transsion` | vlxlxlv/android_hardware_transsion | lineage-22.1 |
| `hardware/mediatek` | LineageOS/android_hardware_mediatek | lineage-23.2 |
| `device/mediatek/sepolicy_vndr` | LineageOS/android_device_mediatek_sepolicy_vndr | lineage-23.2 |
| `vendor/mediatek/ims` | crdroidandroid/android_vendor_mediatek_ims | 16.0 |

`patched-tree/crdroid_X6739.mk` is copied into the device tree during the build:
it mirrors `lineage_X6739.mk` but inherits `vendor/crdroid/config/common_full_phone.mk`
instead of `vendor/lineage`, and is registered in `AndroidProducts.mk` so that

```
lunch crdroid_X6739-userdebug
```

resolves.

## Build

### GitHub Actions (recommended)

1. Push this repo to a **public** GitHub repository (Actions minutes are free and
   unlimited for public repos; private repos get 2,000 minutes/month, which is not
   enough).
2. Actions → *Build crDroid 16 (Android 16) for X6739* → *Run workflow*.
3. Watch the log; the flashable zip is uploaded as the `crDroid16-X6739` artifact.

Runner reality check:

| Runner | Spec | Cost | Notes |
|---|---|---|---|
| `ubuntu-latest` | 4 vCPU / 16 GB / 84 GB | free | sync ~35 min, build likely 6-9 h → **may hit the 6 h job cap** |
| `ubuntu-latest-8-cores` | 8 vCPU / 32 GB / 300 GB | ~$0.022/min ≈ $11/build | needs Team/Enterprise plan |

If the free runner times out, either resume on a larger runner or split the build
across two `workflow_dispatch` runs (sync output is not cached between jobs, so a
larger runner is the simpler fix).

### Locally on any Linux box

```bash
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib \
  git gnupg gperf imagemagick lib32readline-dev lib32z1-dev libelf-dev liblz4-tool \
  libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool \
  squashfs-tools xsltproc zip zlib1g-dev python3
./scripts/build.sh all      # ~25-40 GB source, ~60 GB out, 16 GB RAM + 16 GB swap
```

## Flashing

Requires an unlocked bootloader, A/B slots, and the XOS 14 firmware base.

```bash
adb reboot bootloader
fastboot flash boot        out/target/product/X6739/boot.img
fastboot flash vendor_boot out/target/product/X6739/vendor_boot.img
fastboot flash dtbo        out/target/product/X6739/dtbo.img
adb reboot recovery
# in recovery: wipe data (mandatory when coming from XOS), then sideload
adb sideload crDroidAndroid-16.0-*-X6739-*.zip
```

Always back up IMEI/NVRAM before flashing.

## Known state

* Not yet built end-to-end — the first CI run is the first real test.
* Fingerprint (FOD) is a known weak spot on every custom ROM for this device.
* crDroid is unofficial here, so no OTA updates.
