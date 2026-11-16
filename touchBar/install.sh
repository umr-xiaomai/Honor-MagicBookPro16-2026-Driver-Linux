#!/usr/bin/env bash
# Default: install userspace tool. ACPI changes require a locally built bundle.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
dry_run=0
acpi_dir=""
boot_method=""
requested_boot_method=auto
usage() {
    cat <<'EOF'
Usage: bash touchBar/install.sh [--dry-run] [--acpi-dir DIR]
                               [--boot-method auto|dracut|grub] [--help]
Installs honor-touchpad and an exact-device uaccess rule, with no automatic
hardware writes. Experimental HID commands require a separate CLI opt-in.
--acpi-dir DIR  Install a firmware-specific bundle produced by build.sh.
                Supports dracut (Fedora/openSUSE) or GRUB (Debian/Ubuntu/Arch).
                Requires HONOR XWC-P, matching current firmware, kernel ACPI
                table-upgrade support, and no active kernel lockdown.
--dry-run       Print the plan without changing files or requiring root.
--boot-method   Override automatic initramfs/bootloader selection for ACPI.
EOF
}
while (($#)); do
    case "$1" in
        --dry-run) dry_run=1; shift ;;
        --acpi-dir)
            [[ $# -ge 2 && -n $2 ]] || { echo "Missing --acpi-dir value" >&2; exit 2; }
            acpi_dir=$2; shift 2 ;;
        --boot-method)
            [[ $# -ge 2 ]] || { echo "Missing --boot-method value" >&2; exit 2; }
            requested_boot_method=$2
            case "$requested_boot_method" in auto|dracut|grub) ;; *) echo "Invalid boot method: $2" >&2; exit 2 ;; esac
            shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done
echo "[touchBar] Install /usr/local/bin/honor-touchpad (Python 3)."
echo "[touchBar] Allow active local users access to I2C HID 27c6:0f9a through udev uaccess."
echo "[touchBar] No auto-apply service or HID-BPF loader will be enabled."
if [[ -n $acpi_dir ]]; then
    echo "[touchBar] Validate current firmware against bundle: $acpi_dir"
    echo "[touchBar] Install the validated table through dracut or GRUB and rebuild boot artifacts."
else
    echo "[touchBar] ACPI is unchanged. Build from the running firmware before using --acpi-dir."
fi
((dry_run == 0)) || exit 0
[[ $(uname -s) == Linux ]] || { echo "This installer requires Linux." >&2; exit 1; }
[[ $(id -u) == 0 ]] || { echo "Run with sudo, or use --dry-run." >&2; exit 1; }
command -v python3 >/dev/null || { echo "Install Python 3 first." >&2; exit 1; }
command -v udevadm >/dev/null || { echo "udevadm is required for the hidraw permission rule." >&2; exit 1; }

# Complete firmware/boot preflight before changing any system file.
if [[ -n $acpi_dir ]]; then
    vendor=$(cat /sys/class/dmi/id/sys_vendor)
    product=$(cat /sys/class/dmi/id/product_name)
    [[ ${vendor,,} == *honor* && $product == XWC-P* ]] || {
        echo "ACPI override supports only HONOR XWC-P; found $vendor / $product." >&2; exit 1;
    }
    python3 "$HERE/acpi_override.py" validate "$acpi_dir"
    [[ ! -e /run/ostree-booted ]] || {
        echo "rpm-ostree/immutable systems require their own initramfs workflow; automatic ACPI installation stopped." >&2; exit 1;
    }
    for install_config in /etc/kernel/install.conf /usr/lib/kernel/install.conf; do
        if [[ -f $install_config ]] && grep -Eq '^[[:space:]]*layout[[:space:]]*=[[:space:]]*uki' "$install_config"; then
            echo "UKI kernel-install layout detected; configure the actual UKI generator instead." >&2; exit 1
        fi
    done
    if [[ -r /sys/kernel/security/lockdown ]] && ! grep -q '\[none\]' /sys/kernel/security/lockdown; then
        echo "Kernel lockdown blocks ACPI overrides. ACPI installation stopped." >&2; exit 1
    fi
    python3 - <<'PY'
from pathlib import Path
import sys
for path in Path('/sys/firmware/efi/efivars').glob('SecureBoot-*'):
    data = path.read_bytes()
    if len(data) < 5 or data[4] != 0:
        sys.exit('Secure Boot is enabled or unreadable; ACPI installation stopped.')
PY
    kernel_config="/boot/config-$(uname -r)"
    if [[ -r $kernel_config ]]; then
        grep -Eq '^CONFIG_ACPI_(TABLE_UPGRADE|INITRD_TABLE_OVERRIDE)=y$' "$kernel_config" || {
            echo "Running kernel does not enable ACPI table upgrades." >&2; exit 1;
        }
    elif [[ -r /proc/config.gz ]]; then
        python3 - <<'PY'
import gzip
import re
import sys
with gzip.open('/proc/config.gz', 'rt') as config:
    if not re.search(r'^CONFIG_ACPI_(TABLE_UPGRADE|INITRD_TABLE_OVERRIDE)=y$', config.read(), re.M):
        sys.exit('Running kernel does not enable ACPI table upgrades.')
PY
    else
        echo "Cannot verify kernel ACPI table-upgrade support (missing running kernel config)." >&2; exit 1
    fi
    if [[ $requested_boot_method == dracut ]] || { [[ $requested_boot_method == auto ]] && [[ -f /etc/fedora-release || -f /etc/redhat-release || -f /etc/SuSE-release || -d /etc/zypp ]]; }; then
        command -v dracut >/dev/null || { echo "dracut is required for this ACPI boot method." >&2; exit 1; }
        boot_method=dracut
    elif [[ -f /etc/default/grub ]] && command -v update-grub >/dev/null; then
        boot_method=update-grub
    elif [[ -f /etc/default/grub && -f /boot/grub/grub.cfg ]] && command -v grub-mkconfig >/dev/null; then
        boot_method=grub-mkconfig
    else
        echo "Unsupported automatic ACPI boot integration. Requires dracut or an existing GRUB configuration." >&2
        echo "For an existing dracut workflow use --boot-method dracut. UKI requires its actual image generator." >&2
        exit 1
    fi
    if [[ $boot_method != dracut ]]; then
        command -v cpio >/dev/null || { echo "Install cpio before GRUB ACPI integration." >&2; exit 1; }
    else
        # acpi_table_dir is global: never hide another installed ACPI workaround.
        python3 "$HERE/acpi_override.py" dracut-check
    fi
fi

backup_file() {
    if [[ -e $1 ]]; then
        local backup
        backup="$1.honor-backup.$(date +%Y%m%d%H%M%S).$$"
        cp -a -- "$1" "$backup"
        echo "Backup: $backup"
    fi
}
rollback_dir=$(mktemp -d)
work_dir=""
firmware_pending=0
rollback_paths=()
rollback_present=()
remember_firmware_file() {
    local index=${#rollback_paths[@]}
    rollback_paths+=("$1")
    if [[ -e $1 || -L $1 ]]; then
        cp -a -- "$1" "$rollback_dir/$index"
        rollback_present+=(1)
    else
        rollback_present+=(0)
    fi
}
cleanup() {
    local status=$?
    local restore_failed=0
    set +e
    if ((firmware_pending)); then
        echo "Boot update failed; restoring the previous active firmware files." >&2
        local index
        for ((index=0; index<${#rollback_paths[@]}; index++)); do
            rm -f -- "${rollback_paths[index]}"
            if ((rollback_present[index])); then
                if ! cp -a -- "$rollback_dir/$index" "${rollback_paths[index]}"; then
                    echo "RESTORE FAILED: ${rollback_paths[index]} (backup: $rollback_dir/$index)" >&2
                    restore_failed=1
                fi
            fi
        done
        echo "Some initramfs images may already have been rebuilt. Rebuild with the restored configuration before rebooting." >&2
    fi
    if ((restore_failed == 0)); then rm -rf -- "$rollback_dir"; fi
    if [[ -n $work_dir ]]; then rm -rf -- "$work_dir"; fi
    return "$status"
}
trap cleanup EXIT
backup_file /usr/local/bin/honor-touchpad
install -Dm0755 "$HERE/touchpad_control.py" /usr/local/bin/honor-touchpad
rule=/etc/udev/rules.d/70-honor-touchpad.rules
backup_file "$rule"
install -d /etc/udev/rules.d
cat > "$rule" <<'EOF'
# HONOR I2C Goodix TOPS0102 only; logind grants the active local user access.
SUBSYSTEM=="hidraw", KERNELS=="0018:27C6:0F9A.*", TAG+="uaccess"
EOF
udevadm control --reload-rules
udevadm trigger --subsystem-match=hidraw

# Migrate the known legacy service that wrote defaults as root on boot/resume.
legacy=/etc/systemd/system/honor-touchpad-resume.service
if [[ -f $legacy ]] && grep -q '^ExecStart=/usr/local/bin/honor-touchpad --apply-saved$' "$legacy"; then
    backup_file "$legacy"
    if command -v systemctl >/dev/null && [[ -d /run/systemd/system ]]; then
        systemctl disable --now honor-touchpad-resume.service
    fi
    rm -- "$legacy"
    if command -v systemctl >/dev/null && [[ -d /run/systemd/system ]]; then
        systemctl daemon-reload
    fi
fi

if [[ -n $acpi_dir ]]; then
    if [[ $boot_method == dracut ]]; then
        table_dir=/usr/local/share/honor-touchpad/acpi
        config=/etc/dracut.conf.d/90-honor-touchpad-acpi.conf
        remember_firmware_file "$table_dir/ssdt-touchpad.aml"
        remember_firmware_file "$config"
        firmware_pending=1
        backup_file "$table_dir/ssdt-touchpad.aml"
        backup_file "$config"
        install -Dm0644 "$acpi_dir/ssdt-touchpad.aml" "$table_dir/ssdt-touchpad.aml"
        install -d /etc/dracut.conf.d
        cat > "$config" <<'EOF'
# HONOR firmware-specific ACPI table; dracut puts it in uncompressed early CPIO.
acpi_override="yes"
acpi_table_dir="/usr/local/share/honor-touchpad/acpi"
EOF
        dracut --regenerate-all --force
    else
        remember_firmware_file /boot/acpi-touchpad-override.img
        remember_firmware_file /etc/default/grub
        firmware_pending=1
        backup_file /boot/acpi-touchpad-override.img
        backup_file /etc/default/grub
        work_dir=$(mktemp -d)
        tmp=$work_dir
        mkdir -p "$tmp/kernel/firmware/acpi"
        install -m0644 "$acpi_dir/ssdt-touchpad.aml" "$tmp/kernel/firmware/acpi/ssdt-touchpad.aml"
        (cd "$tmp" && find kernel -print0 | cpio --null -H newc -o --quiet) > "$tmp/override.img"
        install -m0644 "$tmp/override.img" /boot/acpi-touchpad-override.img
        if ! grep -q '^# HONOR touchpad early ACPI override$' /etc/default/grub; then
            cat >> /etc/default/grub <<'EOF'

# HONOR touchpad early ACPI override
case " ${GRUB_EARLY_INITRD_LINUX_CUSTOM:-} " in
    *" acpi-touchpad-override.img "*) ;;
    *) GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi-touchpad-override.img ${GRUB_EARLY_INITRD_LINUX_CUSTOM:-}" ;;
esac
# End HONOR touchpad early ACPI override
EOF
        fi
        if [[ $boot_method == update-grub ]]; then
            update-grub
        else
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
    fi
    firmware_pending=0
    echo "ACPI boot artifacts rebuilt successfully. Reboot and inspect kernel logs to confirm the table loads."
fi
echo "[touchBar] Installed userspace tool. Check: honor-touchpad --status"
echo "[touchBar] Edge-gesture BPF remains experimental: this repository has no complete header/loader integration."
