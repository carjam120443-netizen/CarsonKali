#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$ROOT_DIR/output"
BUILD_DIR="$ROOT_DIR/.build"

mkdir -p "$OUTPUT_DIR" "$BUILD_DIR"
command -v lb >/dev/null || { echo "Error: live-build is not installed."; exit 1; }

cd "$BUILD_DIR"
sudo lb clean --purge || true

sudo lb config \
  --ignore-system-defaults \
  --distribution kali-rolling \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components" \
  --debian-installer false \
  --iso-volume "CARSONKALI" \
  --mirror-bootstrap "http://http.kali.org/kali" \
  --mirror-chroot "http://http.kali.org/kali" \
  --mirror-binary "http://http.kali.org/kali" \
  --security false

# live-build reads these settings from its generated config during later
# stages. Set them after lb config so lb_chroot_archives cannot add the
# nonexistent kali-rolling-updates suite.
cat > config/common <<'EOF'
LB_UPDATES="false"
LB_SECURITY="false"
EOF

# lb config runs as root, so hand the generated config tree back to the runner.
sudo chown -R "$(id -u):$(id -g)" "$BUILD_DIR"

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

sudo lb build

ISO="$(find . -maxdepth 1 -type f -name '*.iso' -print -quit)"
[ -n "$ISO" ] || { echo "Error: no ISO was produced."; exit 1; }

cp "$ISO" "$OUTPUT_DIR/CarsonKali-amd64.iso"
