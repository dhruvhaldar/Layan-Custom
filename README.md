# 🎨 Layan-Custom

<div align="center">

[![GTK](https://img.shields.io/badge/GTK-3.0%20%7C%204.0-blue?logo=gnome)](https://www.gtk.org/)
[![Libadwaita](https://img.shields.io/badge/Libadwaita-1.0%2B-purple?logo=gnome)](https://gitlab.gnome.org/GNOME/libadwaita)
[![GNOME](https://img.shields.io/badge/GNOME-45%20%7C%2046%20%7C%2047%20%7C%2048%20%7C%2050%2B-orange?logo=gnome)](https://www.gnome.org/)
[![License](https://img.shields.io/badge/License-GPLv3-green.svg)](COPYING)
[![Platform](https://img.shields.io/badge/Platform-Linux%20(Arch%20%7C%20Fedora%20%7C%20Ubuntu)-lightgrey)](#)

**A tailored, modernized edition of the iconic Layan GTK theme, engineered for modern GNOME & Libadwaita.**  
*Fixes upstream Libadwaita styling bugs, restores the flush vibrant purple sidebar, refines circular controls, and bundles complete fonts, icons, wallpapers, and turnkey automation.*

</div>

---

## 📑 Table of Contents

- [Why Layan-Custom?](#-why-layan-custom)
- [📦 What's Included](#-whats-included)
- [✨ Key Improvements & Fixes](#-key-improvements--fixes)
- [🚀 Quick Start (One-Shot Install)](#-quick-start)
- [⚙️ Installer Options](#️-installer-options)
- [🔧 Manual Configuration & GSettings Reference](#-manual-configuration--gsettings-reference)
- [🔍 Troubleshooting & Common Fixes](#-troubleshooting--common-fixes)
- [🗑️ Uninstallation](#️-uninstallation)
- [📜 Credits & License](#-credits--license)

---

## 💡 Why Layan-Custom?

The original [Layan theme](https://github.com/vinceliuice/Layan-gtk-theme) is celebrated for its sleek rounded aesthetics and signature deep purple gradients. However, modern GNOME releases (GNOME 45 through 50+) adopt **Libadwaita**, which moved away from standard GTK theme loading.

On modern systems, using upstream Layan out of the box leads to several bugs:
1. **Window Buttons**: Headerbar controls stretch into tall, awkward vertical oval capsules instead of neat circular dots.
2. **Sidebar Breakage**: Nautilus (Files 46+) sidebars shrink into broken 48px slivers or plain dark gray instead of the vibrant purple gradient.
3. **Content Bleed**: Main viewports and file lists can turn purple rather than remaining a readable dark slate.
4. **Operations Popover**: File transfer popovers are semi-transparent (`rgba(60,60,70,0.95)`), letting desktop and terminal text bleed right through.
5. **Horizontal Seams**: A harsh dark dividing line cuts across the sidebar when progress indicators appear.
6. **Corner Leaks**: Sharp blurred red/amber wallpaper corners leak out behind window rounded edges when background blur extensions are enabled.

**`Layan-Custom`** resolves every single one of these issues, packaging all theme assets alongside companion fonts, icons, wallpapers, and an automated setup script that works in seconds.

---

## 📦 What's Included

```
Layan-Custom/
├── install.sh                  # Turnkey installer (themes, fonts, icons, wallpapers, GSettings)
├── uninstall.sh                # Clean uninstaller (restores GNOME defaults)
├── src/                        # Full GTK 2, 3, 4, GNOME Shell, XFWM4 & Plank themes
│   └── libadwaita/             # Custom Libadwaita stylesheets (gtk.css & gtk-dark.css)
├── fonts/                      # Curated companion typography
│   ├── inter/                  # Inter variable & display font family
│   └── jetbrains-mono/         # JetBrains Mono (coding & terminal font)
├── icons/                      # Curated companion icon & cursor packs
│   ├── Tela-dark/              # High-contrast modern flat icons
│   └── catppuccin-...-cursors/ # Sleek rounded mauve cursors (size 36)
└── wallpapers/                 # Dynamic Amber (dark/light) & Layan originals
```

---

## ✨ Key Improvements & Fixes

### 1. Perfectly Circular Window Controls
- Restores macOS-style circular **$13\text{px} \times 13\text{px}$** dots on the right edge (`:minimize,maximize,close`).
- Subtle white translucent resting state (`rgba(255, 255, 255, 0.28)`).
- Distinct hover accents: **Close** (Red `#EF5350`), **Minimize** (Orange `#FFB74D`), **Maximize** (Green `#81C784`).

### 2. Signature Nautilus Purple Pill Pathbar
- Custom gradient pill (`#6a67f4` to `#4e50f9`) for the Nautilus location bar with smooth rounded navigation buttons.

### 3. Consistent Dark Slate Content Views
- Enforces an opaque `#31313a` background across file grids, lists, and viewports. Content stays clear, readable, and immune to color bleeding.

### 4. Full Flush Vibrant Purple Sidebar
- A rich `#6a67f4` $\to$ `#4e50f9` vertical gradient applied seamlessly across both **Nautilus (Files)** and **GNOME Settings (`gnome-control-center`)**.
- Clean white typography, white symbolic icons, and rounded translucent selection pills (`rgba(255, 255, 255, 0.25)`).

### 5. Seamless Progress Indicator
- Completely removes the dark horizontal divider seam above the bottom bar (`.sidebar-pane toolbarview > .bottom-bar`, `undershoot.bottom`).
- Aligns padding (`4px 8px 8px 8px`) to match the $8\text{px}$ margins of sidebar items above.
- Clean rounded pill style with 10px spacing between the animated spinner and label.

### 6. Solid Opaque Operations Popover
- Replaces the translucent popover background with an opaque solid dark slate card (`#2b2b35`), preventing terminal/desktop text from shining through.
- Polished $6\text{px}$ gradient progress bar and circular cancel (`X`) button.

### 7. Curved Window Corner Leak Fix
- Automatically configures Blur My Shell (`applications blur false`) to prevent square wallpaper background blur artifacts behind rounded corners.

### 8. Flatpak & Sandbox Integration
- Grants sandboxed Flatpak applications read-only access to user themes, icons, and fonts, applying `GTK_THEME=Layan-Dark` globally.

---

## 🚀 Quick Start

Run the automated installer from the repository folder:

```bash
cd ~/Layan-Custom
./install.sh
```

### What the installer does automatically:
1. Installs all theme variants to `~/.local/share/themes/`.
2. Deploys the custom Libadwaita stylesheet to `~/.config/gtk-4.0/gtk.css` and `gtk-dark.css`.
3. Installs Inter and JetBrains Mono fonts to `~/.local/share/fonts/` and updates the font cache (`fc-cache`).
4. Installs the `Tela-dark` icon theme and `catppuccin-frappe-mauve-cursors` to `~/.local/share/icons/`.
5. Copies dynamic wallpapers to `~/.local/share/backgrounds/`.
6. Configures GTK 2 (`~/.gtkrc-2.0`) and GTK 3 (`~/.config/gtk-3.0/settings.ini`).
7. Applies all desktop GSettings (themes, fonts, cursors, button layout, wallpapers).
8. Configures Flatpak global theme overrides.
9. Restarts Nautilus to apply changes immediately.

---

## ⚙️ Installer Options

```bash
./install.sh [OPTIONS]
```

| Flag | Parameter | Description | Default |
| :--- | :--- | :--- | :--- |
| `-d`, `--dest` | `DIR` | Themes destination folder | `~/.local/share/themes` |
| `-n`, `--name` | `NAME` | Theme name prefix | `Layan` |
| `-c`, `--color` | `VARIANTS` | Variant(s) to install: `standard`, `dark`, `light` | All |
| `-s`, `--solid` | `VARIANTS` | Window background style: `standard`, `solid` | All |
| `-l`, `--libadwaita`| - | Deploy Libadwaita overrides to `~/.config/gtk-4.0` | Enabled |
| `--no-libadwaita` | - | Skip Libadwaita overrides | - |
| `--no-fonts` | - | Skip installing bundled fonts | - |
| `--no-icons` | - | Skip installing bundled icons and cursors | - |
| `--no-wallpapers`| - | Skip installing bundled wallpapers | - |
| `--no-gsettings` | - | Do not modify GNOME desktop settings | - |
| `--no-flatpak` | - | Skip Flatpak override configuration | - |
| `-u`, `--uninstall`| - | Uninstall themes and restore GNOME defaults | - |
| `-h`, `--help` | - | Show help message | - |

### Useful Command Examples:

- **Install Dark variants only**:
  ```bash
  ./install.sh -c dark
  ```

- **Install system-wide for all users (requires root)**:
  ```bash
  sudo ./install.sh -d /usr/share/themes --no-gsettings
  ```

- **Reinstall without touching desktop fonts or wallpapers**:
  ```bash
  ./install.sh --no-fonts --no-wallpapers
  ```

---

## 🔧 Manual Configuration & GSettings Reference

If you prefer to inspect or apply settings individually:

```bash
# Theme & Dark Mode
gsettings set org.gnome.desktop.interface gtk-theme 'Layan-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.wm.preferences theme 'Layan-Dark'

# Window Button Layout (Dots on Right)
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# Shell Theme (requires User Themes extension)
dconf write /org/gnome/shell/extensions/user-theme/name "'Layan-Dark'"

# Icons & Cursors
gsettings set org.gnome.desktop.interface icon-theme 'Tela-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-frappe-mauve-cursors'
gsettings set org.gnome.desktop.interface cursor-size 36

# Typography
gsettings set org.gnome.desktop.interface font-name 'Inter Display 11'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 12'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Display Bold 11'

# Window Corner Leak Prevention (Blur My Shell)
gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur false
```

---

## 🔍 Troubleshooting & Common Fixes

### 1. Libadwaita apps (Nautilus, Settings) don't show the purple sidebar or custom controls
Libadwaita does not automatically read system GTK themes from `~/.local/share/themes`. It strictly reads `~/.config/gtk-4.0/gtk.css`.
- **Fix**: Run `./install.sh -l` or verify that `~/.config/gtk-4.0/gtk.css` and `gtk-dark.css` exist and contain the `@import` pointing to `Layan-Dark/gtk-4.0/gtk.css`.

### 2. Flatpak applications look unstyled
Flatpak sandbox containers do not have filesystem access to `~/.local/share/themes` by default.
- **Fix**: Run:
  ```bash
  flatpak override --user --filesystem=xdg-data/themes:ro --filesystem=xdg-data/icons:ro --env=GTK_THEME=Layan-Dark
  ```

### 3. GNOME Shell top panel or overview didn't change
GNOME Shell requires the **User Themes** extension to load custom shell themes.
- **Fix**:
  1. Install the `User Themes` extension via GNOME Extension Manager or package manager (`gnome-shell-extension-user-theme`).
  2. Enable the extension and select `Layan-Dark` in GNOME Tweaks $\to$ Appearance $\to$ Shell.

### 4. Customizing the purple accent color
Want a different shade or gradient? Edit `~/.config/gtk-4.0/gtk.css`:
- Modify the `:root` variables (`--sidebar-bg-color`, `--accent-color`).
- Update the gradient stops in section `/* === 4. Full Flush Purple Sidebar === */`:
  ```css
  background-image: linear-gradient(180deg, #YOUR_TOP_COLOR 0%, #YOUR_BOTTOM_COLOR 100%);
  ```

---

## 🗑️ Uninstallation

To cleanly remove all installed themes and restore standard GNOME defaults (`Adwaita`):

```bash
cd ~/Layan-Custom
./uninstall.sh
```

Or using the main installer flag:
```bash
./install.sh --uninstall
```

---

## 📜 Credits & License

- Original theme concept & assets: [Vince Liuice (Layan-gtk-theme)](https://github.com/vinceliuice/Layan-gtk-theme).
- Icon theme: [Tela Icon Theme by Vince Liuice](https://github.com/vinceliuice/Tela-icon-theme).
- Cursor theme: [Catppuccin Cursors](https://github.com/catppuccin/cursors).
- Typography: [Inter by Rasmus Andersson](https://rsms.me/inter/) & [JetBrains Mono](https://www.jetbrains.com/lp/mono/).
- Enhancements, Libadwaita fixes, and installer engineering: **Dhruv Haldar**.
- Released under the **GNU General Public License v3.0** (`COPYING`).
