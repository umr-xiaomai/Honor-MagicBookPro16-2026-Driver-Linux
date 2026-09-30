#!/usr/bin/env bash
#
# touchBar / touchPad installer for HONOR MagicBook Pro 16 2026 (XWC-P)
# Installs ACPI SSDT table override + Touchpad settings utility + Edge gesture BPF
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
IMG_SRC="$HERE/acpi-touchpad-override.img"
AML_SRC="$HERE/ssdt-touchpad.aml"
IMG_DST="/boot/acpi-touchpad-override.img"

echo "=== [touchBar] Installing Touchpad Fix for HONOR MagicBook Pro 16 (XWC-P) ==="

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

# 1. Copy ACPI override image to /boot
echo "[1/4] Copying ACPI override image to /boot..."
if [ -f "$IMG_SRC" ]; then
    cp -v "$IMG_SRC" "$IMG_DST"
    chmod 644 "$IMG_DST"
else
    echo "Error: $IMG_SRC not found!" >&2
    exit 1
fi

# 2. Configure Bootloader / Initramfs based on distribution
echo "[2/4] Configuring bootloader / initramfs..."

if [ -f /etc/arch-release ]; then
    echo "-> Detected Arch Linux / Manjaro."
    mkdir -p /usr/lib/firmware/acpi
    if [ -f "$AML_SRC" ]; then
        cp -v "$AML_SRC" /usr/lib/firmware/acpi/ssdt-touchpad.aml
    fi
    # Add early initrd in grub or mkinitcpio hook
    if grep -q "acpi-touchpad-override.img" /etc/default/grub 2>/dev/null; then
        echo "   GRUB already configured for ACPI override."
    else
        echo "   Adding early initrd to /etc/default/grub..."
        sed -i 's/^GRUB_EARLY_INITRD_LINUX_CUSTOM=.*/GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi-touchpad-override.img"/' /etc/default/grub 2>/dev/null || \
        echo 'GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi-touchpad-override.img"' >> /etc/default/grub
    fi

elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
    echo "-> Detected Fedora / RHEL."
    if [ -d /boot/loader/entries ] && ls /boot/loader/entries/*.conf >/dev/null 2>&1; then
        echo "   Patching BLS entries in /boot/loader/entries..."
        for entry in /boot/loader/entries/*.conf; do
            if ! grep -q "acpi-touchpad-override.img" "$entry"; then
                sed -i 's|^initrd /|initrd /acpi-touchpad-override.img /|' "$entry"
            fi
        done
        # Install kernel-install hook for future kernel updates
        mkdir -p /etc/kernel/install.d
        cat > /etc/kernel/install.d/91-honor-touchpad-acpi.install << 'EOF'
#!/bin/sh
COMMAND="$1"
KERNEL_VERSION="$2"
ENTRY_DIR_OR_FILE="$3"
[ "$COMMAND" = "add" ] || exit 0
[ -f "$ENTRY_DIR_OR_FILE" ] || exit 0
if ! grep -q "acpi-touchpad-override.img" "$ENTRY_DIR_OR_FILE"; then
    sed -i 's|^initrd /|initrd /acpi-touchpad-override.img /|' "$ENTRY_DIR_OR_FILE"
fi
EOF
        chmod +x /etc/kernel/install.d/91-honor-touchpad-acpi.install
    fi

elif [ -f /etc/debian_version ]; then
    echo "-> Detected Ubuntu / Debian."
    if [ -f /etc/default/grub ]; then
        if ! grep -q "acpi-touchpad-override.img" /etc/default/grub; then
            echo "   Adding GRUB_EARLY_INITRD_LINUX_CUSTOM to /etc/default/grub..."
            echo 'GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi-touchpad-override.img"' >> /etc/default/grub
        fi
    fi
else
    echo "-> Generic Linux distribution detected. Ensure /boot/acpi-touchpad-override.img is loaded as the first initrd in your bootloader."
fi

# 3. Install Touchpad Control CLI and Service
echo "[3/4] Installing Touchpad Control Tool (/usr/local/bin/honor-touchpad)..."
cp -v "$HERE/touchpad_control.py" /usr/local/bin/honor-touchpad
chmod +x /usr/local/bin/honor-touchpad

cat > /etc/systemd/system/honor-touchpad-resume.service << 'EOF'
[Unit]
Description=Apply HONOR Touchpad Haptic and Sensitivity Settings on Boot/Resume
After=multi-user.target suspend.target hibernate.target hybrid-sleep.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/honor-touchpad --apply-saved

[Install]
WantedBy=multi-user.target suspend.target hibernate.target hybrid-sleep.target
EOF

systemctl daemon-reload
systemctl enable honor-touchpad-resume.service || true

# 4. Optional: Setup HID-BPF edge gestures if clang/bpftool exists
echo "[4/4] Checking for HID-BPF edge gesture support..."
if [ -f "$HERE/honor-tops0102-edge.bpf.c" ] && command -v clang >/dev/null 2>&1 && command -v bpftool >/dev/null 2>&1; then
    echo "   Compiling honor-tops0102-edge.bpf.o..."
    clang -O2 -target bpf -c "$HERE/honor-tops0102-edge.bpf.c" -o "$HERE/honor-tops0102-edge.bpf.o" || true
fi

echo "=== [touchBar] Installation complete! ==="
