# CarsonKali

**A custom Kali Rolling-based hybrid Linux distribution with KDE Plasma.**

CarsonKali combines a familiar desktop environment with a curated collection of networking, system-diagnostic, and cybersecurity-learning utilities.

> CarsonKali is an independent community project. It is not an official Kali Linux release and is not endorsed by Offensive Security. Kali Linux and related marks belong to their respective owners.

## Project goals

- Kali Rolling as the continuously updated base
- KDE Plasma desktop
- Independent CarsonKali visual identity
- Everyday desktop applications
- Curated networking and system-diagnostic tools
- Reproducible, documented AMD64 Live ISO builds
- VirtualBox-first testing

## Initial release

**0.1.0 Alpha** — initial Live ISO foundation.

## Build

The supported build path uses the official Kali `kali-live` build scripts.

A Kali Rolling build host is recommended. See [docs/BUILDING.md](docs/BUILDING.md) for dependencies and instructions.

Run:

```bash
sudo ./scripts/build-iso.sh
```

The ISO and SHA-256 checksum are written to `dist/`.

## Project layout

- `kali-config/` — CarsonKali package and live-build configuration
- `branding/` — independent visual identity assets and guidelines
- `scripts/` — build and verification scripts
- `.github/workflows/` — manually triggered ISO build workflow
- `docs/` — build instructions and roadmap

## Current status

The project is in early development. The first milestone is a bootable KDE Live ISO. Installer integration, full branding, and additional desktop customization will follow after the base image is tested.

## License

See [LICENSE](LICENSE).
