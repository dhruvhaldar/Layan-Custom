# Layan-Custom

A tailored, modernized edition of the **Layan GTK Theme** designed specifically for modern GNOME (GNOME 45 – 50+) and Libadwaita environments.

This repository bundles all theme variants (GTK 2/3/4, GNOME Shell, XFWM4, Plank) along with a suite of custom Libadwaita refinements, bug fixes, and an automated turnkey installer.

---

## ✨ Features & Custom Improvements

### 1. Perfectly Circular Window Controls
- Standard Libadwaita window control buttons are refined into crisp, circular $13\text{px} \times 13\text{px}$ dots on the right edge (`:minimize,maximize,close`).
- Completely eliminates the tall oval "pill" distortion seen in upstream GTK4 themes.
- Vivid macOS-style hover accents: Close (Red `#EF5350`), Minimize (Orange `#FFB74D`), Maximize (Green `#81C784`).

### 2. Signature Nautilus Purple Pill Pathbar
- Restores the iconic Layan gradient pill (`#6a67f4` to `#4e50f9`) to the Nautilus location pathbar.
- Transparent, rounded inner directory buttons with smooth hover feedback.

### 3. Consistent Dark Slate Content Views
- Enforces an opaque, dark slate background (`#31313a`) across file grids, lists, and viewports.
- Eliminates any accidental purple bleeding into the file explorer content area.

### 4. Full Flush Vibrant Purple Sidebar
- Extends the smooth gradient (`#6a67f4` to `#4e50f9`) seamlessly across sidebars in both **Nautilus (Files)** and **GNOME Settings (`gnome-control-center`)**.
- Rounded selection pills with white icons, white typography, and translucent highlight states.

### 5. Seamless File Operations & Progress Indicator
- **Removed Horizontal Divider Cut**: Stripped unwanted borders, shadows, and background cuts from `.sidebar-pane toolbarview > .bottom-bar` and `undershoot.bottom`.
- **Aligned Margins**: Aligned bottom toolbar padding (`4px 8px 8px 8px`) to match the exact $8\text{px}$ margins of the sidebar items above it.
- **Polished Pill Button**: Rounded $10\text{px}$ button style with balanced spacing between the progress spinner and status text.

### 6. Opaque File Operations Popover
- Completely eliminates the translucent popover background (`rgba(60, 60, 70, 0.95)` in upstream) that caused desktop and terminal text to bleed through.
- Solid `#2b2b35` dark card with subtle drop shadow and refined borders.
- Polished $6\text{px}$ gradient progress bar and circular cancel (`X`) button.

### 7. Curved Window Corner Leak Fix
- Optimizes Blur My Shell configuration (`applications blur false`) to prevent square wallpaper artifacts from leaking past curved window corners.

### 8. Flatpak & Legacy GTK Compatibility
- Automated overrides for Flatpak applications so sandboxed apps inherit `Layan-Dark` and `Tela-dark` icons out of the box.
- Synchronized `~/.config/gtk-3.0/settings.ini` and `~/.gtkrc-2.0` configurations.

---

## 🚀 Quick Start

Clone and run the installer:

```bash
git clone https://github.com/dhruvhaldar/Layan-Custom.git   # or local path
cd Layan-Custom
./install.sh
```

The script automatically:
1. Installs theme files to `~/.local/share/themes/`.
2. Generates and links the custom Libadwaita stylesheet to `~/.config/gtk-4.0/gtk.css` and `gtk-dark.css`.
3. Configures GTK 2.0 and GTK 3.0 configuration files.
4. Applies GNOME GSettings (GTK theme, prefer-dark, button layout `:minimize,maximize,close`).
5. Configures Flatpak global theme overrides (if flatpak is present).
6. Gracefully reloads Nautilus to apply changes immediately.

---

## ⚙️ Advanced Installer Options

```bash
./install.sh [OPTIONS]
```

| Option | Description | Default |
| :--- | :--- | :--- |
| `-d, --dest DIR` | Target themes directory | `~/.local/share/themes` |
| `-n, --name NAME` | Theme name prefix | `Layan` |
| `-c, --color [variants]` | Variants to install (`standard`, `dark`, `light`) | All variants |
| `-s, --solid [variants]` | Window solid style (`standard`, `solid`) | All variants |
| `-l, --libadwaita` | Install modern Libadwaita overrides to `~/.config/gtk-4.0` | Enabled |
| `-g, --gsettings` | Automatically apply GNOME desktop settings | Enabled |
| `-f, --flatpak` | Configure Flatpak global theme overrides | Enabled |
| `-i, --icons` | Clone and install Tela icon theme if missing | Optional |
| `-u, --uninstall` | Cleanly uninstall themes and restore GNOME defaults | - |
| `-h, --help` | Display help message | - |

### Examples:
- **Install Dark variants only**:
  ```bash
  ./install.sh -c dark
  ```

- **Install to system-wide themes (requires sudo)**:
  ```bash
  sudo ./install.sh -d /usr/share/themes --no-gsettings
  ```

- **Uninstall**:
  ```bash
  ./uninstall.sh
  ```

---

## 🎨 Recommended Companion Themes

- **Icons**: [Tela Icon Theme](https://github.com/vinceliuice/Tela-icon-theme) (`Tela-dark`)
- **Shell Theme Extension**: `User Themes` (GNOME Shell extension)

---

## 📜 Credits & License

- Original theme design: [Vince Liuice](https://github.com/vinceliuice/Layan-gtk-theme).
- Licensed under the **GNU General Public License v3.0** (`COPYING`).
