#!/usr/bin/env bash
#
# keyBoard installer for HONOR MagicBook Pro 16 (XWC-P)
# Configures i8042.dumbkbd=1 kernel parameter and Fn key mappings
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "=== [keyBoard] Installing Keyboard Fix & Keymap for HONOR MagicBook Pro 16 ==="

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

# 1. Install udev hwdb rule for Fn hotkeys
echo "[1/2] Installing udev hwdb mapping for Fn hotkeys..."
mkdir -p /etc/udev/hwdb.d
cp -v "$HERE/90-honor-keyboard.hwdb" /etc/udev/hwdb.d/90-honor-keyboard.hwdb
systemd-hwdb update || udevadm hwdb --update || true
udevadm trigger -s input || true

# 2. Add i8042.dumbkbd=1 kernel command-line parameter if needed
echo "[2/2] Checking kernel command-line for i8042.dumbkbd=1..."
PARAM="i8042.dumbkbd=1"

if [ -f /etc/default/grub ]; then
    if ! grep -q "$PARAM" /etc/default/grub; then
        echo "-> Adding $PARAM to /etc/default/grub..."
        sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*/& $PARAM/" /etc/default/grub 2>/dev/null || \
        sed -i "s/GRUB_CMDLINE_LINUX=\"[^\"]*/& $PARAM/" /etc/default/grub
        echo "   Note: GRUB configuration updated. Run update-grub or grub2-mkconfig to apply."
    else
        echo "-> $PARAM is already present in /etc/default/grub."
    fi
elif [ -d /boot/loader/entries ]; then
    for entry in /boot/loader/entries/*.conf; do
        if [ -f "$entry" ] && ! grep -q "$PARAM" "$entry"; then
            sed -i "s/^options .*/& $PARAM/" "$entry"
        fi
    done
fi

echo "=== [keyBoard] Installation complete! ==="
