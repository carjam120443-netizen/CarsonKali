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
mkdir -p "$WORK_DIR/kali-config/common/includes.chroot/usr/share/backgrounds/carsonkali"
mkdir -p "$WORK_DIR/kali-config/common/includes.chroot/etc/skel/Desktop"
mkdir -p "$WORK_DIR/kali-config/variant-xfce/hooks/live"
mkdir -p "$WORK_DIR/kali-config/common/bootloaders/grub-pc/theme"
mkdir -p "$WORK_DIR/kali-config/variant-xfce/package-lists"

cp "$ROOT_DIR/branding/carsonkali-logo.svg" \
  "$WORK_DIR/kali-config/common/includes.chroot/usr/share/pixmaps/carsonkali-logo.svg"
cp "$ROOT_DIR/branding/carsonkali-wallpaper.svg" \
  "$WORK_DIR/kali-config/common/includes.chroot/usr/share/backgrounds/carsonkali/carsonkali-wallpaper.svg"
cp "$ROOT_DIR/branding/grub/config.cfg" \
  "$WORK_DIR/kali-config/common/bootloaders/grub-pc/config.cfg"
cp "$ROOT_DIR/branding/grub/theme.txt" \
  "$WORK_DIR/kali-config/common/bootloaders/grub-pc/theme/theme.txt"

cat > "$WORK_DIR/kali-config/common/includes.chroot/etc/motd" <<'EOF'
CarsonKali

Experimental Kali-based distribution.
Use only on systems you are authorized to test.
EOF

cat > "$WORK_DIR/kali-config/variant-xfce/package-lists/carsonkali.list.chroot" <<'EOF'
kali-linux-default
firefox-esr
network-manager
calamares
EOF

cat > "$WORK_DIR/kali-config/common/includes.chroot/etc/skel/Desktop/Install-CarsonKali.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Install CarsonKali
Comment=Install CarsonKali to disk
Exec=pkexec calamares
Icon=system-software-install
Terminal=false
Categories=System;Settings;
EOF
chmod +x "$WORK_DIR/kali-config/common/includes.chroot/etc/skel/Desktop/Install-CarsonKali.desktop"

# Kali's live-build framework applies live-image hooks from the variant's
# hooks/live directory. Keep all live XFCE customization there.
cat > "$WORK_DIR/kali-config/variant-xfce/hooks/live/0600-carsonkali-xfce.hook.chroot" <<'EOF'
#!/bin/sh
set -e

# XFCE's default panel configuration uses p=6 for the top position.
# p=12 is the bottom border position.
if [ -f /etc/xdg/xfce4/panel/default.xml ]; then
    sed -i 's/value="p=6;x=0;y=0"/value="p=12;x=0;y=0"/g' /etc/xdg/xfce4/panel/default.xml

    mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
    cp /etc/xdg/xfce4/panel/default.xml \
       /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
fi

# Make the installer launcher available to the live user's Desktop.
if id kali >/dev/null 2>&1; then
    mkdir -p /home/kali/Desktop
    cp /etc/skel/Desktop/Install-CarsonKali.desktop /home/kali/Desktop/Install-CarsonKali.desktop
    chown kali:kali /home/kali/Desktop/Install-CarsonKali.desktop
    chmod +x /home/kali/Desktop/Install-CarsonKali.desktop
fi

# Set a system-wide XFCE desktop default and the skeleton default.
mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml
cat > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="last-image" type="string" value="/usr/share/backgrounds/carsonkali/carsonkali-wallpaper.svg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
XML

mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
   /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
EOF
chmod +x "$WORK_DIR/kali-config/variant-xfce/hooks/live/0600-carsonkali-xfce.hook.chroot"

cd "$WORK_DIR"
sudo ./build.sh --arch amd64 --variant xfce --verbose

ISO="$(find "$WORK_DIR/images" -maxdepth 2 -type f -name '*.iso' -print -quit)"
[ -n "$ISO" ] || { echo "Error: no ISO was produced."; exit 1; }

cp "$ISO" "$OUTPUT_DIR/CarsonKali-amd64.iso"
