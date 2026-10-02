#!/usr/bin/env bash
# ==============================================================================
# Layan-Custom - Complete Installer Script
# Optimized and modified Layan GTK theme, Libadwaita styling, icons, fonts & wallpaper
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
prompt()  { echo -e "${C_PURPLE}${C_BOLD}[?]${C_RESET} ${*}"; }

ROOT_UID=0
DEST_DIR=""
ICONS_DIR=""
FONTS_DIR=""
WALLPAPERS_DIR=""

# Determine default destination directories
if [[ "$UID" -eq "$ROOT_UID" ]]; then
  DEST_DIR="/usr/share/themes"
  ICONS_DIR="/usr/share/icons"
  FONTS_DIR="/usr/share/fonts"
  WALLPAPERS_DIR="/usr/share/backgrounds"
elif [[ -n "$XDG_DATA_HOME" ]]; then
  DEST_DIR="$XDG_DATA_HOME/themes"
  ICONS_DIR="$XDG_DATA_HOME/icons"
  FONTS_DIR="$XDG_DATA_HOME/fonts"
  WALLPAPERS_DIR="$XDG_DATA_HOME/backgrounds"
elif [[ -d "$HOME/.local/share/themes" ]]; then
  DEST_DIR="$HOME/.local/share/themes"
  ICONS_DIR="$HOME/.local/share/icons"
  FONTS_DIR="$HOME/.local/share/fonts"
  WALLPAPERS_DIR="$HOME/.local/share/backgrounds"
else
  DEST_DIR="$HOME/.themes"
  ICONS_DIR="$HOME/.icons"
  FONTS_DIR="$HOME/.fonts"
  WALLPAPERS_DIR="$HOME/.local/share/backgrounds"
fi

SRC_DIR=$(cd "$(dirname "$0")" && pwd)
THEME_NAME="Layan"
COLOR_VARIANTS=('' '-Light' '-Dark')
SOLID_VARIANTS=('' '-Solid')

# Feature flags (defaults for all-in-one setup)
INSTALL_LIBADWAITA=true
INSTALL_FONTS=true
INSTALL_ICONS=true
INSTALL_WALLPAPERS=true
APPLY_GSETTINGS=true
APPLY_FLATPAK=true
UNINSTALL=false

# Detect GNOME Shell Version
detect_shell_version() {
  if command -v gnome-shell &>/dev/null; then
    SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f 1)"
    if [[ "${SHELL_VERSION:-0}" -ge "48" ]]; then
      GS_VERSION="48-0"
    elif [[ "${SHELL_VERSION:-0}" -ge "47" ]]; then
      GS_VERSION="47-0"
    elif [[ "${SHELL_VERSION:-0}" -ge "46" ]]; then
      GS_VERSION="46-0"
    elif [[ "${SHELL_VERSION:-0}" -ge "44" ]]; then
      GS_VERSION="44-0"
    elif [[ "${SHELL_VERSION:-0}" -ge "42" ]]; then
      GS_VERSION="42-0"
    elif [[ "${SHELL_VERSION:-0}" -ge "40" ]]; then
      GS_VERSION="40-0"
    else
      GS_VERSION="3-36"
    fi
  else
    GS_VERSION="48-0"
  fi
}

usage() {
cat << EOF
${C_BOLD}Layan-Custom Complete Setup Installer${C_RESET}

${C_CYAN}Usage:${C_RESET}
  $0 [OPTIONS]

${C_CYAN}Options:${C_RESET}
  -d, --dest DIR         Themes destination directory (Default: $DEST_DIR)
  -n, --name NAME        Theme name prefix (Default: $THEME_NAME)
  -c, --color VARIANTS   Color variant(s) [standard|light|dark] (Default: all)
  -s, --solid VARIANTS   Solid variant(s) [standard|solid] (Default: all)
  -l, --libadwaita       Install Libadwaita overrides to ~/.config/gtk-4.0
      --no-libadwaita    Skip Libadwaita / GTK4 overrides
      --no-fonts         Skip installing bundled fonts (Inter & JetBrains Mono)
      --no-icons         Skip installing bundled icons (Tela-dark & cursors)
      --no-wallpapers    Skip installing bundled wallpapers
      --no-gsettings     Skip applying GNOME desktop settings
      --no-flatpak       Skip Flatpak theme overrides
  -u, --uninstall        Uninstall themes, fonts, icons, wallpapers and restore defaults
  -h, --help             Show this help message

${C_CYAN}Examples:${C_RESET}
  ./install.sh                # Full complete setup (themes, libadwaita, icons, fonts, wallpaper, gsettings)
  ./install.sh -c dark        # Dark variants only
  ./install.sh --no-fonts     # Install everything except fonts
  ./install.sh --uninstall    # Remove installed files and restore settings
EOF
}

# Parse options
selected_colors=()
selected_solids=()

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      DEST_DIR="${2}"
      mkdir -p "${DEST_DIR}"
      shift 2
      ;;
    -n|--name)
      THEME_NAME="${2}"
      shift 2
      ;;
    -l|--libadwaita)
      INSTALL_LIBADWAITA=true
      shift
      ;;
    --no-libadwaita)
      INSTALL_LIBADWAITA=false
      shift
      ;;
    --no-fonts)
      INSTALL_FONTS=false
      shift
      ;;
    --no-icons)
      INSTALL_ICONS=false
      shift
      ;;
    --no-wallpapers)
      INSTALL_WALLPAPERS=false
      shift
      ;;
    --no-gsettings)
      APPLY_GSETTINGS=false
      shift
      ;;
    --no-flatpak)
      APPLY_FLATPAK=false
      shift
      ;;
    -u|--uninstall)
      UNINSTALL=true
      shift
      ;;
    -c|--color)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
        case "${1}" in
          standard) selected_colors+=("${COLOR_VARIANTS[0]}") ;;
          light)    selected_colors+=("${COLOR_VARIANTS[1]}") ;;
          dark)     selected_colors+=("${COLOR_VARIANTS[2]}") ;;
          *) error "Unrecognized color variant '$1'"; exit 1 ;;
        esac
        shift
      done
      ;;
    -s|--solid)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
        case "${1}" in
          standard) selected_solids+=("${SOLID_VARIANTS[0]}") ;;
          solid)    selected_solids+=("${SOLID_VARIANTS[1]}") ;;
          *) error "Unrecognized solid variant '$1'"; exit 1 ;;
        esac
        shift
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unrecognized option '$1'"
      usage
      exit 1
      ;;
  esac
done

if [[ "${#selected_colors[@]}" -eq 0 ]]; then
  selected_colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#selected_solids[@]}" -eq 0 ]]; then
  selected_solids=("${SOLID_VARIANTS[@]}")
fi

# ==============================================================================
# Uninstall Procedure
# ==============================================================================
uninstall_all() {
  info "Uninstalling ${THEME_NAME} themes from ${DEST_DIR}..."

  for color in "${COLOR_VARIANTS[@]}"; do
    for solid in "${SOLID_VARIANTS[@]}"; do
      local target="${DEST_DIR}/${THEME_NAME}${color}${solid}"
      if [[ -d "${target}" ]]; then
        rm -rf "${target}"
        success "Removed '${target}'"
      fi
    done
  done

  # Restore GTK-4.0 Libadwaita overrides if they belonged to us
  if [[ -f "${HOME}/.config/gtk-4.0/gtk.css" ]]; then
    if grep -q "Layan" "${HOME}/.config/gtk-4.0/gtk.css" 2>/dev/null; then
      rm -f "${HOME}/.config/gtk-4.0/gtk.css" "${HOME}/.config/gtk-4.0/gtk-dark.css"
      success "Removed custom GTK4 Libadwaita configuration"
    fi
  fi

  # Restore GSettings if available
  if command -v gsettings &>/dev/null; then
    info "Restoring default GNOME settings..."
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' || true
    gsettings set org.gnome.desktop.interface icon-theme 'Adwaita' || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' || true
    gsettings set org.gnome.desktop.wm.preferences theme 'Adwaita' || true
    if command -v dconf &>/dev/null; then
      dconf write /org/gnome/shell/extensions/user-theme/name "''" || true
    fi
  fi

  success "Uninstallation complete!"
  exit 0
}

if [[ "$UNINSTALL" == "true" ]]; then
  uninstall_all
fi

# ==============================================================================
# Install Themes
# ==============================================================================
install_theme_variant() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local solid=${4}

  [[ ${color} == '-Dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-Light' ]] && local ELSE_LIGHT=${color}

  local THEME_DIR="${dest}/${name}${color}${solid}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"
  mkdir -p "${THEME_DIR}"

  info "Installing theme variant to '${THEME_DIR}'..."

  # Metadata
  [[ -f "${SRC_DIR}/COPYING" ]] && cp -f "${SRC_DIR}/COPYING" "${THEME_DIR}/"
  [[ -f "${SRC_DIR}/AUTHORS" ]] && cp -f "${SRC_DIR}/AUTHORS" "${THEME_DIR}/"

  cat > "${THEME_DIR}/index.theme" << EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=${name}${color}${solid}
Comment=A Material Design theme with custom purple flush sidebar & circular controls
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=${name}${color}${solid}
MetacityTheme=${name}${color}${solid}
IconTheme=Tela-dark
CursorTheme=catppuccin-frappe-mauve-cursors
ButtonLayout=:minimize,maximize,close
EOF

  # GNOME Shell
  mkdir -p "${THEME_DIR}/gnome-shell"
  cp -rf "${SRC_DIR}/src/gnome-shell"/{*.svg,noise-texture.png,pad-osd.css} "${THEME_DIR}/gnome-shell/" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/gnome-shell/gnome-shell-theme.gresource.xml" "${THEME_DIR}/gnome-shell/" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/gnome-shell/assets${ELSE_DARK}" "${THEME_DIR}/gnome-shell/assets" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/gnome-shell/common-assets/"*.svg "${THEME_DIR}/gnome-shell/assets/" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/gnome-shell/shell-${GS_VERSION}/gnome-shell${ELSE_DARK}.css" "${THEME_DIR}/gnome-shell/gnome-shell.css" 2>/dev/null || true

  # GTK-2.0
  mkdir -p "${THEME_DIR}/gtk-2.0"
  cp -rf "${SRC_DIR}/src/gtk-2.0"/{apps.rc,hacks.rc,main.rc,panel.rc} "${THEME_DIR}/gtk-2.0/" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/gtk-2.0/assets${ELSE_DARK}" "${THEME_DIR}/gtk-2.0/assets" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/gtk-2.0/gtkrc${color}" "${THEME_DIR}/gtk-2.0/gtkrc" 2>/dev/null || true

  # GTK Assets
  cp -rf "${SRC_DIR}/src/gtk/assets" "${THEME_DIR}/gtk-assets"

  # GTK-3.0
  mkdir -p "${THEME_DIR}/gtk-3.0"
  ln -sf ../gtk-assets "${THEME_DIR}/gtk-3.0/assets"
  cp -rf "${SRC_DIR}/src/gtk/3.0/gtk${color}${solid}.css" "${THEME_DIR}/gtk-3.0/gtk.css" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/gtk/3.0/gtk-Dark${solid}.css" "${THEME_DIR}/gtk-3.0/gtk-dark.css" 2>/dev/null || true

  # GTK-4.0
  mkdir -p "${THEME_DIR}/gtk-4.0"
  ln -sf ../gtk-assets "${THEME_DIR}/gtk-4.0/assets"
  cp -rf "${SRC_DIR}/src/gtk/4.0/gtk${color}${solid}.css" "${THEME_DIR}/gtk-4.0/gtk.css" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/gtk/4.0/gtk-Dark${solid}.css" "${THEME_DIR}/gtk-4.0/gtk-dark.css" 2>/dev/null || true

  # XFWM4 & Plank
  mkdir -p "${THEME_DIR}/xfwm4"
  cp -rf "${SRC_DIR}/src/xfwm4/assets${ELSE_LIGHT}"/*.png "${THEME_DIR}/xfwm4/" 2>/dev/null || true
  cp -rf "${SRC_DIR}/src/xfwm4/themerc${ELSE_LIGHT}" "${THEME_DIR}/xfwm4/themerc" 2>/dev/null || true

  cp -rf "${SRC_DIR}/src/plank" "${THEME_DIR}/" 2>/dev/null || true
}

# ==============================================================================
# Install Bundled Fonts
# ==============================================================================
install_fonts() {
  if [[ ! -d "${SRC_DIR}/fonts" ]]; then
    return
  fi

  info "Installing bundled fonts (Inter & JetBrains Mono) to '${FONTS_DIR}'..."
  mkdir -p "${FONTS_DIR}/inter" "${FONTS_DIR}/jetbrains-mono"

  cp -rf "${SRC_DIR}/fonts/inter/"* "${FONTS_DIR}/inter/" 2>/dev/null || true
  cp -rf "${SRC_DIR}/fonts/jetbrains-mono/"* "${FONTS_DIR}/jetbrains-mono/" 2>/dev/null || true

  if command -v fc-cache &>/dev/null; then
    info "Updating system font cache..."
    fc-cache -f "${FONTS_DIR}" 2>/dev/null || true
  fi
  success "Fonts installed successfully!"
}

# ==============================================================================
# Install Bundled Icons & Cursors
# ==============================================================================
install_icons_and_cursors() {
  if [[ ! -d "${SRC_DIR}/icons" ]]; then
    return
  fi

  info "Installing bundled icons & cursors to '${ICONS_DIR}'..."
  mkdir -p "${ICONS_DIR}"

  if [[ -d "${SRC_DIR}/icons/Tela-dark" ]]; then
    info "Installing 'Tela-dark' icon theme..."
    cp -rf "${SRC_DIR}/icons/Tela-dark" "${ICONS_DIR}/"
  fi

  if [[ -d "${SRC_DIR}/icons/Bibata-Modern-Classic" ]]; then
    info "Installing 'Bibata-Modern-Classic'..."
    cp -rf "${SRC_DIR}/icons/Bibata-Modern-Classic" "${ICONS_DIR}/"
  fi

  if [[ -d "${SRC_DIR}/icons/catppuccin-frappe-mauve-cursors" ]]; then
    info "Installing 'catppuccin-frappe-mauve-cursors'..."
    cp -rf "${SRC_DIR}/icons/catppuccin-frappe-mauve-cursors" "${ICONS_DIR}/"
  fi

  # Create legacy ~/.icons symlink if running as user
  if [[ "$UID" -ne "$ROOT_UID" && ! -e "${HOME}/.icons" ]]; then
    ln -s "${ICONS_DIR}" "${HOME}/.icons" 2>/dev/null || true
  fi

  success "Icons and cursors installed successfully!"
}

# ==============================================================================
# Install Bundled Wallpapers
# ==============================================================================
install_wallpapers() {
  if [[ ! -d "${SRC_DIR}/wallpapers" ]]; then
    return
  fi

  info "Installing bundled wallpapers to '${WALLPAPERS_DIR}'..."
  mkdir -p "${WALLPAPERS_DIR}"
  cp -rf "${SRC_DIR}/wallpapers/"* "${WALLPAPERS_DIR}/" 2>/dev/null || true
  success "Wallpapers installed successfully!"
}

# ==============================================================================
# Libadwaita Custom Configuration (~/.config/gtk-4.0)
# ==============================================================================
configure_libadwaita() {
  local target_theme_dir="${DEST_DIR}/${THEME_NAME}-Dark"
  local gtk4_conf_dir="${HOME}/.config/gtk-4.0"

  info "Deploying custom Libadwaita / GTK4 stylesheet to '${gtk4_conf_dir}'..."
  mkdir -p "${gtk4_conf_dir}"

  local template="${SRC_DIR}/src/libadwaita/gtk-dark.css"
  if [[ -f "${template}" ]]; then
    sed "s|@THEME_DIR@|${target_theme_dir}|g" "${template}" > "${gtk4_conf_dir}/gtk-dark.css"
    cp -f "${gtk4_conf_dir}/gtk-dark.css" "${gtk4_conf_dir}/gtk.css"
    success "Configured ~/.config/gtk-4.0/gtk.css and gtk-dark.css"
  fi
}

# ==============================================================================
# Legacy GTK Config Files (~/.gtkrc-2.0 & ~/.config/gtk-3.0/settings.ini)
# ==============================================================================
configure_legacy_gtk() {
  local gtk3_dir="${HOME}/.config/gtk-3.0"
  mkdir -p "${gtk3_dir}"

  info "Configuring GTK 3.0 settings in '${gtk3_dir}/settings.ini'..."
  cat > "${gtk3_dir}/settings.ini" << EOF
[Settings]
gtk-theme-name=${THEME_NAME}-Dark
gtk-icon-theme-name=Tela-dark
gtk-application-prefer-dark-theme=1
EOF

  info "Configuring GTK 2.0 settings in '${HOME}/.gtkrc-2.0'..."
  cat > "${HOME}/.gtkrc-2.0" << EOF
include "${DEST_DIR}/${THEME_NAME}-Dark/gtk-2.0/gtkrc"
gtk-theme-name="${THEME_NAME}-Dark"
gtk-icon-theme-name="Tela-dark"
EOF
}

# ==============================================================================
# Desktop GSettings Configuration
# ==============================================================================
apply_desktop_settings() {
  if ! command -v gsettings &>/dev/null; then
    warn "gsettings not available, skipping desktop settings."
    return
  fi

  info "Applying complete GNOME desktop settings..."

  # Theme & Dark Mode
  gsettings set org.gnome.desktop.interface gtk-theme "${THEME_NAME}-Dark" || true
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
  gsettings set org.gnome.desktop.wm.preferences theme "${THEME_NAME}-Dark" || true
  gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close' || true

  # Icons & Cursors
  if [[ -d "${ICONS_DIR}/Tela-dark" || -d "${HOME}/.icons/Tela-dark" || -d "/usr/share/icons/Tela-dark" ]]; then
    gsettings set org.gnome.desktop.interface icon-theme 'Tela-dark' || true
  fi

  if [[ -d "${ICONS_DIR}/Bibata-Modern-Classic" || -d "${HOME}/.icons/Bibata-Modern-Classic" || -d "/usr/share/icons/Bibata-Modern-Classic" ]]; then
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' || true
    gsettings set org.gnome.desktop.interface cursor-size 48 || true
  elif [[ -d "${ICONS_DIR}/catppuccin-frappe-mauve-cursors" || -d "${HOME}/.icons/catppuccin-frappe-mauve-cursors" ]]; then
    gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-frappe-mauve-cursors' || true
    gsettings set org.gnome.desktop.interface cursor-size 36 || true
  fi

  # Fonts
  gsettings set org.gnome.desktop.interface font-name 'Inter Display 11' || true
  gsettings set org.gnome.desktop.interface document-font-name 'Inter 11' || true
  gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 12' || true
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Display Bold 11' || true

  # Wallpaper
  local dark_wp=""
  local light_wp=""
  if [[ -f "${WALLPAPERS_DIR}/amber-d.jxl" ]]; then
    dark_wp="file://${WALLPAPERS_DIR}/amber-d.jxl"
    light_wp="file://${WALLPAPERS_DIR}/amber-l.jxl"
  elif [[ -f "${WALLPAPERS_DIR}/amber-d.jpg" ]]; then
    dark_wp="file://${WALLPAPERS_DIR}/amber-d.jpg"
    light_wp="file://${WALLPAPERS_DIR}/amber-l.jpg"
  elif [[ -f "${WALLPAPERS_DIR}/layan-dark.png" ]]; then
    dark_wp="file://${WALLPAPERS_DIR}/layan-dark.png"
    light_wp="file://${WALLPAPERS_DIR}/layan-light.png"
  fi

  if [[ -n "${dark_wp}" ]]; then
    gsettings set org.gnome.desktop.background picture-uri-dark "${dark_wp}" || true
    gsettings set org.gnome.desktop.background picture-uri "${light_wp:-$dark_wp}" || true
    gsettings set org.gnome.desktop.background primary-color '#ff7800' || true
    gsettings set org.gnome.desktop.background picture-options 'zoom' || true
  fi

  # Shell theme
  if command -v dconf &>/dev/null; then
    dconf write /org/gnome/shell/extensions/user-theme/name "'${THEME_NAME}-Dark'" 2>/dev/null || true
  fi

  # Corner leak fix: disable Blur My Shell application blur if active
  if gsettings list-schemas 2>/dev/null | grep -q "org.gnome.shell.extensions.blur-my-shell"; then
    info "Optimizing Blur My Shell settings to prevent corner artifacts..."
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur false 2>/dev/null || true
  fi

  success "GNOME settings applied successfully!"
}

# ==============================================================================
# Flatpak Theme Override
# ==============================================================================
configure_flatpak() {
  if ! command -v flatpak &>/dev/null; then
    return
  fi

  info "Configuring Flatpak global theme overrides..."
  flatpak override --user \
    --filesystem=xdg-data/themes:ro \
    --filesystem=xdg-data/icons:ro \
    --filesystem=xdg-data/fonts:ro \
    --filesystem=~/.themes:ro \
    --filesystem=~/.icons:ro \
    --filesystem=~/.fonts:ro \
    --env=GTK_THEME="${THEME_NAME}-Dark" \
    --env=ICON_THEME="Tela-dark" 2>/dev/null || true
  success "Flatpak overrides configured!"
}

# ==============================================================================
# Main Execution
# ==============================================================================
echo -e "${C_PURPLE}${C_BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║                  Layan-Custom Complete Setup                          ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo -e "${C_RESET}"

detect_shell_version
info "Detected GNOME Shell profile: ${GS_VERSION}"
info "Installing to destination: ${DEST_DIR}"

mkdir -p "${DEST_DIR}"

# Create legacy symlinks (~/.themes and ~/.icons)
if [[ "$UID" -ne "$ROOT_UID" ]]; then
  [[ ! -e "${HOME}/.themes" ]] && ln -s "${DEST_DIR}" "${HOME}/.themes" 2>/dev/null || true
  [[ ! -e "${HOME}/.icons" ]] && ln -s "${ICONS_DIR}" "${HOME}/.icons" 2>/dev/null || true
fi

# 1. Install selected theme variants
for color in "${selected_colors[@]}"; do
  for solid in "${selected_solids[@]}"; do
    install_theme_variant "${DEST_DIR}" "${THEME_NAME}" "${color}" "${solid}"
  done
done

# 2. Install Fonts
if [[ "$INSTALL_FONTS" == "true" ]]; then
  install_fonts
fi

# 3. Install Icons & Cursors
if [[ "$INSTALL_ICONS" == "true" ]]; then
  install_icons_and_cursors
fi

# 4. Install Wallpapers
if [[ "$INSTALL_WALLPAPERS" == "true" ]]; then
  install_wallpapers
fi

# 5. Modern Libadwaita Overrides
if [[ "$INSTALL_LIBADWAITA" == "true" && "$UID" -ne "$ROOT_UID" ]]; then
  configure_libadwaita
fi

# 6. Legacy GTK Configs
if [[ "$UID" -ne "$ROOT_UID" ]]; then
  configure_legacy_gtk
fi

# 7. Flatpak Overrides
if [[ "$APPLY_FLATPAK" == "true" && "$UID" -ne "$ROOT_UID" ]]; then
  configure_flatpak
fi

# 8. Desktop GSettings
if [[ "$APPLY_GSETTINGS" == "true" && "$UID" -ne "$ROOT_UID" ]]; then
  apply_desktop_settings
fi

# Restart Nautilus to apply changes immediately
if command -v nautilus &>/dev/null; then
  nautilus -q 2>/dev/null || true
fi

echo ""
success "${C_BOLD}Layan-Custom installation completed successfully!${C_RESET}"
echo -e "${C_CYAN}Themes, icons, fonts, wallpaper and settings have been applied!${C_RESET}\n"
