#!/usr/bin/env bash
#
# Unified One-Click Linux Driver & Fix Installer
# Target Machine: HONOR MagicBook Pro 16 2026 (XWC-P)
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}"
echo "============================================================"
echo "    HONOR MagicBook Pro 16 (XWC-P) Linux Driver Suite       "
echo "               One-Click Setup Installer                    "
echo "============================================================"
echo -e "${NC}"

# 1. Root check
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] This installer must be run as root.${NC}" >&2
    echo "Please execute: sudo ./install.sh" >&2
    exit 1
fi

# 2. Secure Boot Check
echo -e "${BOLD}[Step 1/4] Checking UEFI Secure Boot Status...${NC}"
if command -v mokutil >/dev/null 2>&1; then
    if mokutil --sb-state 2>/dev/null | grep -iq "SecureBoot enabled"; then
        echo -e "${RED}${BOLD}[CRITICAL WARNING]${NC}"
        echo -e "${YELLOW}Secure Boot is currently ${RED}ENABLED${YELLOW}.${NC}"
        echo -e "${YELLOW}Linux Kernel Lockdown will SILENTLY BLOCK initrd ACPI table overrides,${NC}"
        echo -e "${YELLOW}causing the touchpad fix to fail to load!${NC}"
        echo -e "Please reboot into BIOS (press F2 upon power on) and set ${BOLD}Secure Boot -> Disabled${NC}."
        echo ""
        read -p "Do you want to continue anyway? [y/N]: " -r choice
        case "$choice" in
            [yY][eE][sS]|[yY]) echo "Continuing installation...";;
            *) echo "Aborted. Please disable Secure Boot first."; exit 1;;
        esac
    else
        echo -e "${GREEN}✓ Secure Boot is disabled. ACPI table override will load properly.${NC}"
    fi
else
    echo "Note: 'mokutil' not found, skipping Secure Boot check. Ensure Secure Boot is Disabled in BIOS."
fi

# 3. Hardware check
echo -e "\n${BOLD}[Step 2/4] Verifying Hardware Model...${NC}"
if [ -f /sys/class/dmi/id/product_name ]; then
    PROD=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")
    echo "-> DMI Product Name: $PROD"
    if [[ "$PROD" != *"XWC-P"* && "$PROD" != *"MagicBook"* ]]; then
        echo -e "${YELLOW}Notice: Device $PROD is not strictly 'XWC-P', but fixes are likely compatible with 2026 MagicBook AI models.${NC}"
    else
        echo -e "${GREEN}✓ Verified HONOR MagicBook Pro 16 platform.${NC}"
    fi
fi

# 4. Install Submodules
echo -e "\n${BOLD}[Step 3/4] Installing Device Modules...${NC}"

# Module 1: touchBar (Pressure Touchpad & Gestures)
if [ -f "$ROOT_DIR/touchBar/install.sh" ]; then
    echo -e "\n${BLUE}--> Installing [touchBar] module...${NC}"
    bash "$ROOT_DIR/touchBar/install.sh"
fi

# Module 2: keyBoard (Internal Keyboard & Fn Hotkeys)
if [ -f "$ROOT_DIR/keyBoard/install.sh" ]; then
    echo -e "\n${BLUE}--> Installing [keyBoard] module...${NC}"
    bash "$ROOT_DIR/keyBoard/install.sh"
fi

# Module 3: audioCodec (ALC256 & Headphone mic)
if [ -f "$ROOT_DIR/audioCodec/install.sh" ]; then
    echo -e "\n${BLUE}--> Installing [audioCodec] module...${NC}"
    bash "$ROOT_DIR/audioCodec/install.sh"
fi

# Module 4: fingerPrint (Goodix 27c6:6f94 permissions)
if [ -f "$ROOT_DIR/fingerPrint/install.sh" ]; then
    echo -e "\n${BLUE}--> Installing [fingerPrint] module...${NC}"
    bash "$ROOT_DIR/fingerPrint/install.sh"
fi

# Module 5: batteryCharge (Battery Health Limit)
if [ -f "$ROOT_DIR/batteryCharge/install.sh" ]; then
    echo -e "\n${BLUE}--> Installing [batteryCharge] module...${NC}"
    bash "$ROOT_DIR/batteryCharge/install.sh"
fi

# 5. Bootloader & Initramfs Regeneration
echo -e "\n${BOLD}[Step 4/4] Updating Bootloader & Initramfs...${NC}"

# Debian / Ubuntu
if command -v update-grub >/dev/null 2>&1; then
    echo "-> Running update-grub..."
    update-grub || true
elif command -v grub2-mkconfig >/dev/null 2>&1; then
    echo "-> Running grub2-mkconfig..."
    grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || \
    grub2-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
elif command -v grub-mkconfig >/dev/null 2>&1; then
    echo "-> Running grub-mkconfig..."
    grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
fi

# Initramfs
if command -v update-initramfs >/dev/null 2>&1; then
    echo "-> Running update-initramfs -u..."
    update-initramfs -u || true
elif command -v dracut >/dev/null 2>&1; then
    echo "-> Regenerating initramfs with dracut..."
    dracut --force || true
elif command -v mkinitcpio >/dev/null 2>&1; then
    echo "-> Regenerating initramfs with mkinitcpio..."
    mkinitcpio -P || true
fi

echo -e "\n${GREEN}${BOLD}============================================================${NC}"
echo -e "${GREEN}${BOLD}           All modules installed successfully!              ${NC}"
echo -e "${GREEN}${BOLD}============================================================${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${BOLD}Reboot your computer${NC} to apply ACPI table and kernel changes:"
echo -e "     ${YELLOW}sudo reboot${NC}"
echo ""
echo -e "  2. After reboot, test the touchpad and adjust sensitivity:"
echo -e "     ${YELLOW}honor-touchpad --gui${NC}      (Launch graphical settings panel)"
echo -e "     ${YELLOW}honor-touchpad --status${NC}   (Verify device status)"
echo ""
echo -e "  3. Edge gestures:"
echo -e "     • Right edge slide: System volume (Out of the box)"
echo -e "     • Left edge slide: Screen brightness (HID-BPF enabled)"
echo ""
