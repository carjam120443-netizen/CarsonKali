# CarsonKali visual identity

CarsonKali has its own visual identity. It does not use Kali Linux's dragon logo, wallpapers, boot artwork, or official branding.

## Design system

- **Primary background:** deep charcoal / midnight navy
- **Primary accent:** electric violet (#8A6BFF)
- **Secondary accent:** cool cyan (#55D9E8)
- **Text:** soft white (#EBF0FF), with muted blue-grey for secondary text
- **Typography:** clean sans-serif, prioritizing readability
- **Motif:** geometric lines, rings, and a restrained technical grid
- **Wordmark:** CarsonKali
- **Tagline:** Explore • Learn • Build

## Repository assets

- `icons/carsonkali-mark.svg` — original CK monogram
- `wallpapers/carsonkali-default.svg` — 3840×2160 desktop wallpaper
- `CarsonKali.colors` — KDE Plasma color scheme
- `plymouth/` — future boot splash theme
- `grub/` — future boot menu theme

## ISO integration

The ISO build script copies the logo, wallpaper, and KDE color scheme into the live filesystem:

- `/usr/share/backgrounds/carsonkali/`
- `/usr/share/icons/hicolor/scalable/apps/`
- `/usr/share/pixmaps/`
- `/usr/share/color-schemes/`

The wallpaper and color scheme are installed and available to select in KDE. The current build does not yet force them as the default Plasma wallpaper/theme, and the upstream bootloader and Plymouth visuals have not yet been replaced.

All assets are original project artwork. CarsonKali is independent and is not endorsed by Offensive Security.
