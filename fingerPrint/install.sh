#!/usr/bin/env bash
#
# fingerPrint installer for HONOR MagicBook Pro 16 (XWC-P)
# Installs udev rules for Goodix 27c6:6f94 fingerprint sensor
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "=== [fingerPrint] Installing Fingerprint Rules (Goodix 27c6:6f94) ==="

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

mkdir -p /etc/udev/rules.d
cp -v "$HERE/70-goodix-fingerprint.rules" /etc/udev/rules.d/70-goodix-fingerprint.rules
udevadm control --reload || true
udevadm trigger -s usb || true

echo "=== [fingerPrint] Installation complete! ==="
