# Building CarsonKali

## Recommended build host

Use a dedicated Kali Rolling or compatible Debian-based Linux build environment. Building an ISO requires root privileges and substantial free disk space. A VM is recommended; do not experiment on a production system.

The first target is AMD64 (x86_64).

## Dependencies

On Kali Rolling:

```bash
sudo apt update
sudo apt install -y git live-build apt-utils qemu-user-binfmt ca-certificates
```

## Build

From the repository root:

```bash
chmod +x scripts/build-iso.sh
sudo ./scripts/build-iso.sh
```

The script clones the official Kali `kali-live` build scripts into the ignored `.build/` directory, replaces the upstream KDE package list with CarsonKali's curated list (including the Calamares installer package and Zsh), and installs the project's original branding assets into the live filesystem before building the `kali-rolling` KDE variant.

The build currently installs these assets:

- `/usr/share/backgrounds/carsonkali/carsonkali-default.svg`
- `/usr/share/icons/hicolor/scalable/apps/carsonkali.svg`
- `/usr/share/pixmaps/carsonkali.svg`
- `/usr/share/color-schemes/CarsonKali.colors`

The wallpaper and KDE color scheme are available in the live desktop but are not yet configured as defaults. Plymouth and GRUB still need their own CarsonKali themes.

Output:

- `dist/CarsonKali-0.1.0-alpha-amd64.iso`
- `dist/CarsonKali-0.1.0-alpha-amd64.iso.sha256`

The first build downloads a large number of packages and can take a while. Keep ample free disk space available.

## Build options

The script supports the upstream build options through environment variables:

- `BUILD_BRANCH` — defaults to `kali-rolling`
- `BUILD_VERSION` — defaults to `0.1.0-alpha`
- `BUILD_ARCH` — defaults to `amd64`

Example:

```bash
sudo BUILD_VERSION=0.1.1-alpha ./scripts/build-iso.sh
```

## Test in VirtualBox

Create a new Linux VM and attach the generated ISO as a virtual optical disk.

Suggested starting settings:

- Type: Linux
- Version: Debian (64-bit)
- RAM: 4–6 GB
- CPUs: 2–4
- Virtual disk: 40 GB
- EFI: enabled if testing the UEFI boot path

Test both the live desktop and basic hardware/network behavior before attempting installation. Do not write the ISO to a physical disk as part of routine VM testing.

## Upstream references

- [Kali custom ISO documentation](https://www.kali.org/docs/development/live-build-a-custom-kali-iso/)
- [Kali Live build scripts](https://gitlab.com/kalilinux/build-scripts/kali-live)
