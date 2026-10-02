#!/usr/bin/env bash
# ==============================================================================
# Layan-Custom - Desktop Settings Applicator (apply-settings.sh)
# Configures themes, icons, cursors, typography, wallpapers, window buttons & fixes
# ==============================================================================

set -e

# Styling & colors
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GREEN="\033[32m"
C_BLUE="\033[34m"
C_CYAN="\033[36m"
C_YELLOW="\033[33m"
C_RED="\033[31m"
C_PURPLE="\033[35m"

info()    { echo -e "${C_BLUE}${C_BOLD}[INFO]${C_RESET} ${*}"; }
success() { echo -e "${C_GREEN}${C_BOLD}[SUCCESS]${C_RESET} ${*}"; }
warn()    { echo -e "${C_YELLOW}${C_BOLD}[WARNING]${C_RESET} ${*}"; }
error()   { echo -e "${C_RED}${C_BOLD}[ERROR]${C_RESET} ${*}"; }

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Defaults
THEME_NAME="Layan-Dark"
ICON_THEME="Tela-dark"
CURSOR_THEME="Bibata-Modern-Classic"
CURSOR_SIZE=48
WALLPAPER_CHOICE="amber"
APPLY_FLATPAK=true
APPLY_FONTS=true

usage() {
cat << EOF
${C_BOLD}Layan-Custom Desktop Settings Applicator${C_RESET}

${C_CYAN}Usage:${C_RESET}
  $0 [OPTIONS]

${C_CYAN}Options:${C_RESET}
  --theme THEME          GTK theme name (Default: ${THEME_NAME})
  --icons ICONS          Icon theme name (Default: ${ICON_THEME})
  --cursor CURSOR        Cursor theme [bibata|catppuccin|<name>] (Default: Bibata-Modern-Classic)
  --cursor-size SIZE     Cursor size in pixels (Default: 48)
  --wallpaper CHOICE     Wallpaper preset [amber|layan|<path>] (Default: amber)
  --no-fonts             Do not modify font settings
  --no-flatpak           Skip Flatpak theme overrides
  -h, --help             Show this help message

${C_CYAN}Examples:${C_RESET}
  ./apply-settings.sh                               # Apply complete desktop configuration
  ./apply-settings.sh --cursor catppuccin --cursor-size 36
  ./apply-settings.sh --wallpaper layan
EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
  case "${1}" in
    --theme)
      THEME_NAME="${2}"
      shift 2
      ;;
    --icons)
      ICON_THEME="${2}"
      shift 2
      ;;
    --cursor)
      case "${2}" in
        bibata|bibata-classic) CURSOR_THEME="Bibata-Modern-Classic" ;;
        catppuccin|catppuccin-mauve) CURSOR_THEME="catppuccin-frappe-mauve-cursors" ;;
        *) CURSOR_THEME="${2}" ;;
      esac
      shift 2
      ;;
    --cursor-size)
      CURSOR_SIZE="${2}"
      shift 2
      ;;
    --wallpaper)
      WALLPAPER_CHOICE="${2}"
      shift 2
      ;;
    --no-fonts)
      APPLY_FONTS=false
      shift
      ;;
    --no-flatpak)
      APPLY_FLATPAK=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown option '$1'"
      usage
      exit 1
      ;;
  esac
done

echo -e "${C_PURPLE}${C_BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║             Applying Layan-Custom Desktop Settings                    ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo -e "${C_RESET}"

# 1. GTK Theme & Dark Mode
if command -v gsettings &>/dev/null; then
  info "Configuring GTK theme: ${THEME_NAME} (prefer-dark)..."
  gsettings set org.gnome.desktop.interface gtk-theme "${THEME_NAME}"
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.wm.preferences theme "${THEME_NAME}"

  # 2. Window Controls (Dots on right)
  info "Configuring window controls layout (:minimize,maximize,close)..."
  gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

  # 3. Shell Theme
  if command -v dconf &>/dev/null; then
    info "Configuring GNOME Shell user theme: ${THEME_NAME}..."
    dconf write /org/gnome/shell/extensions/user-theme/name "'${THEME_NAME}'" 2>/dev/null || true
  fi

  # 4. Icon Theme
  info "Configuring icon theme: ${ICON_THEME}..."
  gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}"

  # 5. Cursor Theme & Size
  info "Configuring cursor theme: ${CURSOR_THEME} (${CURSOR_SIZE}px)..."
  gsettings set org.gnome.desktop.interface cursor-theme "${CURSOR_THEME}"
  gsettings set org.gnome.desktop.interface cursor-size "${CURSOR_SIZE}"

  # 6. Typography
  if [[ "$APPLY_FONTS" == "true" ]]; then
    info "Configuring typography (Inter Display 11, JetBrains Mono 12)..."
    gsettings set org.gnome.desktop.interface font-name 'Inter Display 11'
    gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 12'
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Display Bold 11'
  fi

  # 7. Wallpaper
  info "Configuring wallpaper preset: ${WALLPAPER_CHOICE}..."
  wp_dark=""
  wp_light=""

  case "${WALLPAPER_CHOICE}" in
    amber)
      if [[ -f "/usr/share/backgrounds/gnome/amber-d.jxl" ]]; then
        wp_dark="file:///usr/share/backgrounds/gnome/amber-d.jxl"
        wp_light="file:///usr/share/backgrounds/gnome/amber-l.jxl"
      elif [[ -f "${SCRIPT_DIR}/wallpapers/amber-d.jpg" ]]; then
        wp_dark="file://${SCRIPT_DIR}/wallpapers/amber-d.jpg"
        wp_light="file://${SCRIPT_DIR}/wallpapers/amber-l.jpg"
      fi
      ;;
    layan)
      if [[ -f "${SCRIPT_DIR}/wallpapers/layan-dark.png" ]]; then
        wp_dark="file://${SCRIPT_DIR}/wallpapers/layan-dark.png"
        wp_light="file://${SCRIPT_DIR}/wallpapers/layan-light.png"
      fi
      ;;
    file://*|/*)
      wp_dark="${WALLPAPER_CHOICE}"
      wp_light="${WALLPAPER_CHOICE}"
      ;;
  esac

  if [[ -n "${wp_dark}" ]]; then
    gsettings set org.gnome.desktop.background picture-uri-dark "${wp_dark}"
    gsettings set org.gnome.desktop.background picture-uri "${wp_light:-$wp_dark}"
    gsettings set org.gnome.desktop.background primary-color '#ff7800'
    gsettings set org.gnome.desktop.background picture-options 'zoom'
  fi

  # 8. Corner Artifact Fix (Blur My Shell)
  if gsettings list-schemas 2>/dev/null | grep -q "org.gnome.shell.extensions.blur-my-shell"; then
    info "Applying Blur My Shell corner leak fix (applications blur: false)..."
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur false 2>/dev/null || true
  fi
else
  warn "gsettings command not found; skipping GNOME GSettings."
fi

# 9. GTK 2.0 and GTK 3.0 Configuration Files
info "Updating GTK 3.0 configuration (~/.config/gtk-3.0/settings.ini)..."
mkdir -p "${HOME}/.config/gtk-3.0"
cat > "${HOME}/.config/gtk-3.0/settings.ini" << EOF
[Settings]
gtk-theme-name=${THEME_NAME}
gtk-icon-theme-name=${ICON_THEME}
gtk-cursor-theme-name=${CURSOR_THEME}
gtk-cursor-theme-size=${CURSOR_SIZE}
gtk-font-name=Inter Display 11
gtk-application-prefer-dark-theme=1
EOF

info "Updating GTK 2.0 configuration (~/.gtkrc-2.0)..."
cat > "${HOME}/.gtkrc-2.0" << EOF
gtk-theme-name="${THEME_NAME}"
gtk-icon-theme-name="${ICON_THEME}"
gtk-cursor-theme-name="${CURSOR_THEME}"
gtk-cursor-theme-size=${CURSOR_SIZE}
gtk-font-name="Inter Display 11"
EOF

# 10. Flatpak Overrides
if [[ "$APPLY_FLATPAK" == "true" ]] && command -v flatpak &>/dev/null; then
  info "Configuring Flatpak global environment & filesystem overrides..."
  flatpak override --user \
    --filesystem=xdg-data/themes:ro \
    --filesystem=xdg-data/icons:ro \
    --filesystem=xdg-data/fonts:ro \
    --filesystem=~/.themes:ro \
    --filesystem=~/.icons:ro \
    --filesystem=~/.fonts:ro \
    --env=GTK_THEME="${THEME_NAME}" \
    --env=ICON_THEME="${ICON_THEME}" 2>/dev/null || true
fi

# 11. Gracefully reload Nautilus if running
if command -v nautilus &>/dev/null; then
  nautilus -q 2>/dev/null || true
fi

echo ""
success "${C_BOLD}All Layan-Custom desktop settings applied successfully!${C_RESET}"
echo -e "Theme:   ${C_CYAN}${THEME_NAME}${C_RESET}"
echo -e "Icons:   ${C_CYAN}${ICON_THEME}${C_RESET}"
echo -e "Cursor:  ${C_CYAN}${CURSOR_THEME} (${CURSOR_SIZE}px)${C_RESET}"
echo -e "Fonts:   ${C_CYAN}Inter Display 11 / JetBrains Mono 12${C_RESET}"
echo -e "Buttons: ${C_CYAN}:minimize,maximize,close (Right dots)${C_RESET}\n"
