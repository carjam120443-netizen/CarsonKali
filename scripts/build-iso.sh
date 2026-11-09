#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="$ROOT/.build"
UPSTREAM="$BUILD_ROOT/kali-live"
OUTPUT="$BUILD_ROOT/output"
DIST="$ROOT/dist"

UPSTREAM_URL="https://gitlab.com/kalilinux/build-scripts/kali-live.git"
BRANCH="${BUILD_BRANCH:-kali-rolling}"
VERSION="${BUILD_VERSION:-0.1.0-alpha}"
ARCH="${BUILD_ARCH:-amd64}"
HOSTNAME="carsonkali"
PACKAGE_LIST="$ROOT/kali-config/variant-kde/package-lists/kali.list.chroot"

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Kali Live Build requires root privileges."
    echo "Run: sudo $0"
    exit 1
fi

for command in git find sha256sum; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $command"
        exit 1
    fi
done

if [[ ! -f "$PACKAGE_LIST" ]]; then
    echo "ERROR: CarsonKali KDE package list is missing: $PACKAGE_LIST"
    exit 1
fi

mkdir -p "$BUILD_ROOT" "$OUTPUT" "$DIST"

echo "========================================"
echo "          CarsonKali ISO Builder"
echo "========================================"
echo "Branch:   $BRANCH"
echo "Variant:  kde"
echo "Arch:     $ARCH"
echo "Version:  $VERSION"
echo

if [[ ! -d "$UPSTREAM/.git" ]]; then
    echo "[1/4] Cloning official Kali Live build scripts..."
    git clone --depth 1 --branch main "$UPSTREAM_URL" "$UPSTREAM"
else
    echo "[1/4] Updating official Kali Live build scripts..."
    git -C "$UPSTREAM" pull --ff-only
fi

echo "[2/4] Applying CarsonKali package selection and visual identity..."
install -D -m 0644 "$PACKAGE_LIST" \
    "$UPSTREAM/kali-config/variant-kde/package-lists/kali.list.chroot"

INCLUDES="$UPSTREAM/kali-config/common/includes.chroot"
install -D -m 0644 "$ROOT/branding/wallpapers/carsonkali-default.svg" \
    "$INCLUDES/usr/share/backgrounds/carsonkali/carsonkali-default.svg"
install -D -m 0644 "$ROOT/branding/icons/carsonkali-mark.svg" \
    "$INCLUDES/usr/share/icons/hicolor/scalable/apps/carsonkali.svg"
install -D -m 0644 "$ROOT/branding/icons/carsonkali-mark.svg" \
    "$INCLUDES/usr/share/pixmaps/carsonkali.svg"
install -D -m 0644 "$ROOT/branding/CarsonKali.colors" \
    "$INCLUDES/usr/share/color-schemes/CarsonKali.colors"

echo "[3/4] Building CarsonKali Live ISO..."
mkdir -p "$OUTPUT"
BUILD_ARGS=(
    --arch "$ARCH"
    --branch "$BRANCH"
    --variant kde
    --version "$VERSION"
    --hostname "$HOSTNAME"
    --output "$OUTPUT"
)

if [[ "${BUILD_DEBUG:-0}" == "1" ]]; then
    DEBUG=1 "$UPSTREAM/build.sh" "${BUILD_ARGS[@]}"
else
    "$UPSTREAM/build.sh" "${BUILD_ARGS[@]}"
fi

echo "[4/4] Collecting ISO and generating checksum..."
ISO_PATH="$(find "$OUTPUT" -maxdepth 1 -type f -name '*.iso' -printf '%T@ %p\n' \
    | sort -nr | head -n 1 | cut -d ' ' -f 2-)"

if [[ -z "$ISO_PATH" || ! -f "$ISO_PATH" ]]; then
    echo "ERROR: Build finished without producing an ISO."
    echo "Inspect the build log and output directory: $OUTPUT"
    exit 1
fi

FINAL_ISO="$DIST/CarsonKali-0.1.0-alpha-amd64.iso"
if [[ "$VERSION" != "0.1.0-alpha" || "$ARCH" != "amd64" ]]; then
    FINAL_ISO="$DIST/CarsonKali-$VERSION-$ARCH.iso"
fi

install -m 0644 "$ISO_PATH" "$FINAL_ISO"
sha256sum "$FINAL_ISO" > "$FINAL_ISO.sha256"

echo
echo "BUILD SUCCESSFUL"
echo "ISO:      $FINAL_ISO"
echo "Checksum: $FINAL_ISO.sha256"
