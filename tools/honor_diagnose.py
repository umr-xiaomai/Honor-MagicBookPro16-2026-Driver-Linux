#!/usr/bin/env python3
"""Read-only Linux diagnostics. Standard library only; never writes hardware."""

import argparse
import hashlib
import json
from pathlib import Path
import platform
import re
import shlex
import shutil
import struct
import subprocess
import sys


LOG_PATTERN = re.compile(r"acpi.*(?:error|override|upgrade|I2C_DEVT)|AE_AML|i2c.hid|TOPS010|27c6|sof.*(?:error|fail)|snd.*(?:error|fail)|i8042|atkbd", re.I)


def read_text(path):
    try:
        return path.read_text(encoding="utf-8", errors="replace").strip()
    except OSError:
        return None


def read_pairs(path, shell_values=True):
    result = {}
    for line in (read_text(path) or "").splitlines():
        if "=" in line and not line.startswith("#"):
            key, value = line.split("=", 1)
            if not shell_values:
                result[key] = value
                continue
            try:
                parsed = shlex.split(value)
            except ValueError:
                continue
            result[key] = parsed[0] if parsed else ""
    return result


def acpi_header(path):
    data = path.read_bytes()
    if len(data) < 36:
        raise ValueError("short ACPI header")
    signature, length, _, _, oem, table_id, oem_revision, _, _ = struct.unpack_from("<4sIBB6s8sI4sI", data)
    return {
        "file": path.name,
        "signature": signature.decode("ascii", errors="replace"),
        "oem_id": oem.decode("ascii", errors="replace").strip(),
        "oem_table_id": table_id.decode("ascii", errors="replace").strip(),
        "oem_revision": oem_revision,
        "length": length,
        "valid": length == len(data) and sum(data) % 256 == 0,
        "sha256": hashlib.sha256(data).hexdigest(),
    }


def secure_boot(sys_root):
    files = sorted((sys_root / "firmware/efi/efivars").glob("SecureBoot-*"))
    if not files:
        return "unknown (EFI variable unavailable)"
    try:
        data = files[0].read_bytes()
        if len(data) < 5 or data[4] not in (0, 1):
            return "unknown (invalid EFI variable)"
        return "enabled" if data[4] else "disabled"
    except OSError as exc:
        return f"unknown ({exc.strerror or type(exc).__name__})"


def file_size(path):
    try:
        # sysfs reports size=4096 for binary attributes: count actual bytes.
        return len(path.read_bytes())
    except OSError:
        return None


def collect(sys_root=Path("/sys"), proc_root=Path("/proc"), etc_root=Path("/etc")):
    dmi = sys_root / "class/dmi/id"
    commands = ("dracut", "lsinitrd", "update-initramfs", "update-grub", "grub-mkconfig", "grubby", "mkinitcpio", "iasl", "udevadm", "fprintd-enroll", "mokutil")
    report = {
        "system": {"distribution": read_pairs(etc_root / "os-release"), "kernel": platform.release(), "machine": platform.machine()},
        "dmi": {key: read_text(dmi / key) for key in ("sys_vendor", "product_name", "bios_version", "bios_date")},
        "secure_boot": secure_boot(sys_root),
        "lockdown": read_text(sys_root / "kernel/security/lockdown"),
        "tools": {tool: shutil.which(tool) is not None for tool in commands},
        "acpi": [], "hidraw": [], "fingerprint": [], "battery": [], "audio_codecs": [], "notes": [],
    }
    for path in sorted((sys_root / "firmware/acpi/tables").glob("SSDT*")):
        try:
            header = acpi_header(path)
            if header["oem_table_id"] in ("I2C_DEVT", "I2CDEVC"):
                report["acpi"].append(header)
        except (OSError, ValueError) as exc:
            report["notes"].append(f"Cannot inspect {path.name}: {exc}")
    for node in sorted((sys_root / "class/hidraw").glob("hidraw*")):
        # HID_UNIQ may contain a serial number; only report hardware IDs.
        fields = read_pairs(node / "device/uevent", shell_values=False)
        report["hidraw"].append({"node": "/dev/" + node.name, **{key: fields.get(key) for key in ("HID_ID", "HID_NAME")}, "descriptor_bytes": file_size(node / "device/report_descriptor")})
    for node in sorted((sys_root / "bus/usb/devices").glob("*")):
        vid = (read_text(node / "idVendor") or "").lower()
        pid = (read_text(node / "idProduct") or "").lower()
        if vid == "27c6":
            report["fingerprint"].append({"usb_id": f"{vid}:{pid}", "product": read_text(node / "product"), "known_target": pid == "6f94"})
    for node in sorted((sys_root / "class/power_supply").glob("*")):
        if read_text(node / "type") != "Battery":
            continue
        report["battery"].append({"name": node.name, "status": read_text(node / "status"), **{key: read_text(node / key) for key in ("charge_control_start_threshold", "charge_control_end_threshold")}})
    report["wmi_charge_thresholds"] = {driver: read_text(sys_root / "devices/platform" / driver / "charge_control_thresholds") for driver in ("huawei-wmi", "honor-wmi")}
    for path in sorted((proc_root / "asound").glob("card*/codec*")):
        text = read_text(path)
        if text:
            report["audio_codecs"].append({"file": str(path.relative_to(proc_root)), "identification": [line for line in text.splitlines() if line.startswith(("Codec:", "Vendor Id:", "Subsystem Id:"))]})
    for config in (etc_root / "modprobe.d/alsa-honor.conf", etc_root / "udev/rules.d/70-goodix-fingerprint.rules", etc_root / "default/grub", etc_root / "dracut.conf.d/90-honor-touchpad-acpi.conf"):
        if config.is_file():
            # GRUB defaults may contain custom credentials: emit presence only.
            report.setdefault("installed_configuration", {})[str(config)] = "present" if config.name == "grub" else read_text(config)
    # Do not emit the full cmdline, which can contain credentials.
    report["keyboard_parameters"] = [arg for arg in (read_text(proc_root / "cmdline") or "").split() if arg.startswith(("i8042.", "atkbd."))]
    return report


def kernel_log():
    """Capture relevant current-boot lines; missing privilege is visible."""
    command = ["journalctl", "-k", "-b", "--no-pager", "-o", "cat"] if shutil.which("journalctl") else ["dmesg"]
    try:
        result = subprocess.run(command, capture_output=True, text=True, errors="replace", timeout=20, check=False)
    except (OSError, subprocess.TimeoutExpired) as exc:
        return {"error": str(exc)}
    if result.returncode:
        return {"error": result.stderr.strip() or f"exit {result.returncode}"}
    return {"lines": [line for line in result.stdout.splitlines() if LOG_PATTERN.search(line)][-250:], "notice": result.stderr.strip() or None}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="Print a machine-readable report")
    parser.add_argument("--logs", action="store_true", help="Include relevant current-boot kernel logs (sudo may be needed)")
    args = parser.parse_args(argv)
    if sys.platform != "linux":
        print("Run this diagnostic in the installed Linux system; Windows/WSL cannot report Linux hardware state.", file=sys.stderr)
        return 1
    report = collect()
    if args.logs:
        report["kernel_log"] = kernel_log()
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        for key, value in report.items():
            print(f"{key}: {json.dumps(value, ensure_ascii=False, indent=2)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
