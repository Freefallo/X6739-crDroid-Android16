#!/usr/bin/env bash
#
# crDroid 12 (Android 16) for Infinix GT 10 Pro (X6739)
#
# Usage:
#   ./scripts/build.sh sync     # init + sync source and apply device trees
#   ./scripts/build.sh build    # compile (assumes sync done)
#   ./scripts/build.sh all      # both
#
set -euo pipefail

ROM_BRANCH="${ROM_BRANCH:-16.0}"
MANIFEST_URL="${MANIFEST_URL:-https://github.com/crdroidandroid/android}"
DEVICE="X6739"
LUNCH_TARGET="crdroid_${DEVICE}-userdebug"
JOBS="${JOBS:-$(nproc)}"
TOP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }

need() {
    command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 1; }
}

setup_repo_tool() {
    if ! command -v repo >/dev/null 2>&1; then
        need curl
        log "installing repo tool"
        mkdir -p "$HOME/bin"
        curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o "$HOME/bin/repo"
        chmod +x "$HOME/bin/repo"
        export PATH="$HOME/bin:$PATH"
    fi
}

do_sync() {
    cd "$TOP"
    setup_repo_tool

    log "repo init (branch ${ROM_BRANCH}, shallow + partial clone to fit CI disk)"
    repo init \
        -u "$MANIFEST_URL" \
        -b "$ROM_BRANCH" \
        --depth=1 \
        --partial-clone \
        --clone-filter=blob:limit=2m \
        --no-tags

    log "installing local_manifests/X6739.xml"
    mkdir -p .repo/local_manifests
    cp -f "$TOP/local_manifests/X6739.xml" .repo/local_manifests/

    log "repo sync -j${JOBS} (this is the long one: ~25-40 GB)"
    repo sync -c -j"${JOBS}" --force-sync --no-clone-bundle --no-tags --optimized-fetch

    apply_trees
}

apply_trees() {
    cd "$TOP"
    log "applying crDroid product makefile to the device tree"
    local dt="device/infinix/${DEVICE}"
    [ -d "$dt" ] || { echo "device tree missing at $dt" >&2; exit 1; }
    cp -f "$TOP/patched-tree/crdroid_${DEVICE}.mk" "$dt/crdroid_${DEVICE}.mk"

    # Register the product so `lunch crdroid_X6739-userdebug` resolves.
    # Appending keeps the lineage_* entry intact, so lineange-X6739 builds too.
    if ! grep -q "crdroid_${DEVICE}.mk" "$dt/AndroidProducts.mk"; then
        printf '\nPRODUCT_MAKEFILES += crdroid_%s.mk\n' "$DEVICE" >> "$dt/AndroidProducts.mk"
    fi
    log "AndroidProducts.mk:"
    grep -n 'PRODUCT_MAKEFILES\|crdroid' "$dt/AndroidProducts.mk" || true
}

do_build() {
    cd "$TOP"
    log "building ${LUNCH_TARGET} with -j${JOBS}"
    set +u
    # shellcheck disable=SC1091
    source build/envsetup.sh
    lunch "$LUNCH_TARGET"
    set -u
    mka bacon -j"${JOBS}" 2>&1 | tee "$TOP/build.log"

    log "output"
    ls -la out/target/product/"${DEVICE}"/crDroid*.zip 2>/dev/null || {
        echo "no crDroid zip produced, check build.log" >&2
        exit 1
    }
}

case "${1:-all}" in
    sync)  do_sync ;;
    build) do_build ;;
    all)   do_sync; do_build ;;
    *)     echo "usage: $0 {sync|build|all}" >&2; exit 2 ;;
esac
