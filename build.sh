#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$ROOT_DIR/.kali-live"
OUTPUT_DIR="$ROOT_DIR/output"

mkdir -p "$OUTPUT_DIR"

rm -rf "$WORK_DIR"
git clone --depth 1 https://gitlab.com/kalilinux/build-scripts/kali-live.git "$WORK_DIR"

# Use Kali's maintained Live ISO framework, then layer CarsonKali customizations on top.
mkdir -p "$WORK_DIR/kali-config/common/includes.chroot/etc"
mkdir -p "$WORK_DIR/kali-config/common/includes.chroot/usr/share/pixmaps"
mkdir -p "$WORK_DIR/kali-config/variant-xfce/package-lists"

cp "$ROOT_DIR/branding/carsonkali-logo.svg"   "$WORK_DIR/kali-config/common/includes.chroot/usr/share/pixmaps/carsonkali-logo.svg"

cat > "$WORK_DIR/kali-config/common/includes.chroot/etc/motd" <<'EOF'
CarsonKali

Experimental Kali-based distribution.
Use only on systems you are authorized to test.
EOF

cat > "$WORK_DIR/kali-config/variant-xfce/package-lists/carsonkali.list.chroot" <<'EOF'
kali-linux-default
firefox-esr
network-manager
EOF

cd "$WORK_DIR"
sudo ./build.sh --arch amd64 --variant xfce --verbose

ISO="$(find "$WORK_DIR/images" -maxdepth 2 -type f -name '*.iso' -print -quit)"
[ -n "$ISO" ] || { echo "Error: no ISO was produced."; exit 1; }

cp "$ISO" "$OUTPUT_DIR/CarsonKali-amd64.iso"
