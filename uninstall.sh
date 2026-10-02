#!/usr/bin/env bash
# ==============================================================================
# Layan-Custom - Uninstaller Script
# ==============================================================================

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
exec bash "${SCRIPT_DIR}/install.sh" --uninstall "$@"
