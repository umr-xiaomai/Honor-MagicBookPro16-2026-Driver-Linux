#!/usr/bin/bash
#
# Recompile ssdt-touchpad.asl and repackage the initrd ACPI-override image.
# Deps: iasl, cpio  (Fedora: sudo dnf install acpica-tools cpio)
#
# You normally do NOT need this — prebuilt ssdt-touchpad.aml and
# acpi-touchpad-override.img are already included. Use it only if you edit the ASL.
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Compiling ssdt-touchpad.asl"
iasl -tc ssdt-touchpad.asl >/tmp/iasl.log 2>&1
grep -q "0 Errors" /tmp/iasl.log || { echo "compile failed:"; cat /tmp/iasl.log; exit 1; }
echo "    OK: ssdt-touchpad.aml"

echo "==> Packaging acpi-touchpad-override.img"
tmp="$(mktemp -d)"
mkdir -p "$tmp/kernel/firmware/acpi"
cp ssdt-touchpad.aml "$tmp/kernel/firmware/acpi/SSDT-I2CDEVC.aml"
( cd "$tmp" && find kernel | cpio -H newc -o --quiet ) > acpi-touchpad-override.img
rm -rf "$tmp" ssdt-touchpad.hex
echo "    OK: acpi-touchpad-override.img ($(stat -c%s acpi-touchpad-override.img) bytes)"
