#!/usr/bin/env bash
#
# audioCodec installer for HONOR MagicBook Pro 16 (XWC-P)
# Installs ALSA/SOF sound card quirks for ALC256 and internal mic array
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "=== [audioCodec] Installing Audio Fixes for HONOR MagicBook Pro 16 ==="

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

mkdir -p /etc/modprobe.d
cp -v "$HERE/alsa-honor.conf" /etc/modprobe.d/alsa-honor.conf

# Unmute headphones auto-mute if amixer exists
if command -v amixer >/dev/null 2>&1; then
    amixer -c 0 set "Auto-Mute Mode" Enabled 2>/dev/null || true
fi

echo "=== [audioCodec] Installation complete! ==="
