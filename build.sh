#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$ROOT_DIR/output"
BUILD_DIR="$ROOT_DIR/.build"

mkdir -p "$OUTPUT_DIR" "$BUILD_DIR"
command -v lb >/dev/null || { echo "Error: live-build is not installed."; exit 1; }

cd "$BUILD_DIR"
lb clean --purge || true

lb config   --distribution kali-rolling   --architectures amd64   --binary-images iso-hybrid   --archive-areas "main contrib non-free non-free-firmware"   --bootappend-live "boot=live components"   --debian-installer false

mkdir -p config/package-lists config/includes.chroot/etc

cat > config/package-lists/carsonkali.list.chroot <<'EOF'
kali-desktop-xfce
kali-linux-default
firefox-esr
network-manager
EOF

cat > config/includes.chroot/etc/motd <<'EOF'
CarsonKali

Experimental Kali-based distribution.
Use only on systems you are authorized to test.
EOF

lb build

ISO="$(find . -maxdepth 1 -type f -name '*.iso' -print -quit)"
[ -n "$ISO" ] || { echo "Error: no ISO was produced."; exit 1; }

cp "$ISO" "$OUTPUT_DIR/CarsonKali-amd64.iso"
