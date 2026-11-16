#!/usr/bin/env bash
# Optional device permissions; this does not implement a fingerprint driver.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            echo 'Usage: bash fingerPrint/install.sh [--dry-run]'
            echo 'Install active-session uaccess permissions for detected Goodix 27c6:6f94.'
            echo 'Fingerprint operation additionally requires a compatible libfprint driver.'
            exit 0 ;;
        *) echo "Unknown argument: $arg" >&2; exit 2 ;;
    esac
done
if (( DRY_RUN )); then
    echo '[dry-run] Detect Goodix 27c6:6f94; install USB-device-only uaccess permissions.'
    exit 0
fi
[[ $(uname -s) == Linux ]] || { echo 'This installer requires Linux.' >&2; exit 1; }
(( EUID == 0 )) || { echo 'Run this installer with sudo.' >&2; exit 1; }
command -v udevadm >/dev/null || { echo 'udevadm is required.' >&2; exit 1; }
found=0
for device in /sys/bus/usb/devices/*; do
    [[ -r $device/idVendor && -r $device/idProduct ]] || continue
    if [[ $(cat "$device/idVendor") == 27c6 && $(cat "$device/idProduct") == 6f94 ]]; then
        found=1
        break
    fi
done
(( found )) || { echo 'Goodix 27c6:6f94 is absent; skipping permission rule.'; exit 0; }
install -d /etc/udev/rules.d
target=/etc/udev/rules.d/70-goodix-fingerprint.rules
if [[ -f $target ]] && ! cmp -s "$HERE/70-goodix-fingerprint.rules" "$target"; then
    cp -a "$target" "$target.bak.$(date +%s)"
fi
install -m 0644 "$HERE/70-goodix-fingerprint.rules" "$target"
udevadm control --reload-rules
udevadm trigger --action=add --subsystem-match=usb --attr-match=idVendor=27c6 --attr-match=idProduct=6f94
udevadm settle
echo 'Goodix permission rule installed. Run fprintd-list with your normal login name to verify support.'
echo 'If fprintd reports no devices, a compatible libfprint driver is still required.'
