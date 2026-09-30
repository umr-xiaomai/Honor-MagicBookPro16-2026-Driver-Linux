#!/usr/bin/env bash
#
# batteryCharge installer for HONOR MagicBook Pro 16 (XWC-P)
# Installs battery charge threshold tool and systemd boot service
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "=== [batteryCharge] Installing Battery Protection & Charge Limit ==="

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

cp -v "$HERE/honor-battery-limit.sh" /usr/local/bin/honor-battery-limit
chmod +x /usr/local/bin/honor-battery-limit

cp -v "$HERE/honor-battery-limit.service" /etc/systemd/system/honor-battery-limit.service
systemctl daemon-reload
systemctl enable honor-battery-limit.service || true

# Apply default 80% limit now
/usr/local/bin/honor-battery-limit 80 || true

echo "=== [batteryCharge] Installation complete! ==="
