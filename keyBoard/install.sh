#!/usr/bin/env bash
# Install the XWC-P keymap; the legacy controller workaround is opt-in.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=keyBoard/grub-config.sh
source "$HERE/grub-config.sh"
DRY_RUN=0
DUMBKBD=0
usage() {
    cat <<'EOF'
Usage: bash keyBoard/install.sh [--dry-run] [--enable-dumbkbd]
Install the HONOR XWC-P Fn keymap. --enable-dumbkbd additionally installs
i8042.dumbkbd=1 using grubby or the detected GRUB configuration generator.
EOF
}
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --enable-dumbkbd) DUMBKBD=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $arg" >&2; usage >&2; exit 2 ;;
    esac
done
if (( DRY_RUN )); then
    echo '[dry-run] Install XWC-P-only keymap; rebuild hwdb and reload input devices.'
    (( ! DUMBKBD )) || echo '[dry-run] Add i8042.dumbkbd=1 using grubby or a managed /etc/default/grub block and rebuild GRUB.'
    exit 0
fi
[[ $(uname -s) == Linux ]] || { echo 'This installer requires Linux.' >&2; exit 1; }
(( EUID == 0 )) || { echo 'Run this installer with sudo.' >&2; exit 1; }
[[ $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) == HONOR && $(cat /sys/class/dmi/id/product_name 2>/dev/null) == XWC-P ]] || {
    echo 'Refusing keyboard changes: this module is scoped to HONOR XWC-P.' >&2; exit 1;
}
command -v udevadm >/dev/null || { echo 'udevadm is required.' >&2; exit 1; }
boot_method=
if (( DUMBKBD )); then
    if command -v grubby >/dev/null; then
        boot_method=grubby
    elif command -v update-grub >/dev/null && [[ -f /etc/default/grub ]]; then
        boot_method=update-grub
    elif command -v grub2-mkconfig >/dev/null && [[ -f /etc/default/grub && -f /boot/grub2/grub.cfg ]]; then
        boot_method=grub2-mkconfig
    elif command -v grub-mkconfig >/dev/null && [[ -f /etc/default/grub && -f /boot/grub/grub.cfg ]]; then
        boot_method=grub-mkconfig
    else
        echo 'No supported boot updater found. Add i8042.dumbkbd=1 through your boot manager manually.' >&2; exit 1
    fi
fi
install -d /etc/udev/hwdb.d
target=/etc/udev/hwdb.d/90-honor-keyboard.hwdb
if [[ -f $target ]] && ! cmp -s "$HERE/90-honor-keyboard.hwdb" "$target"; then
    cp -a "$target" "$target.bak.$(date +%s)"
fi
install -m 0644 "$HERE/90-honor-keyboard.hwdb" "$target"
if command -v systemd-hwdb >/dev/null; then
    systemd-hwdb update
else
    udevadm hwdb --update
fi
udevadm trigger --subsystem-match=input
if (( DUMBKBD )); then
    if [[ $boot_method == grubby ]]; then
        grubby --update-kernel=ALL --args='i8042.dumbkbd=1'
    else
        case "$boot_method" in
            update-grub) honor_keyboard_apply_grub_workaround /etc/default/grub update-grub ;;
            grub2-mkconfig) honor_keyboard_apply_grub_workaround /etc/default/grub grub2-mkconfig -o /boot/grub2/grub.cfg ;;
            grub-mkconfig) honor_keyboard_apply_grub_workaround /etc/default/grub grub-mkconfig -o /boot/grub/grub.cfg ;;
        esac
    fi
    echo 'Keyboard-controller workaround installed; reboot to apply.'
fi
echo 'XWC-P keymap installed. Check the actual Fn key events with evtest.'
