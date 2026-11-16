import importlib.util
from pathlib import Path
import struct
import tempfile
import unittest


SPEC = importlib.util.spec_from_file_location("honor_diagnose", Path(__file__).resolve().parents[1] / "tools/honor_diagnose.py")
diagnose = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(diagnose)


def table(oem_id=b"I2C_DEVT", body=b"abc"):
    data = bytearray(struct.pack("<4sIBB6s8sI4sI", b"SSDT", 36 + len(body), 2, 0, b"HONOR ", oem_id, 4096, b"INTL", 0) + body)
    data[9] = -sum(data) % 256
    return data


class DiagnosticsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.sys = self.root / "sys"
        self.proc = self.root / "proc"
        self.etc = self.root / "etc"

    def write(self, relative, data):
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data if isinstance(data, bytes) else data.encode())
        return path

    def test_missing_hardware_is_reported_without_failure(self):
        report = diagnose.collect(self.sys, self.proc, self.etc)
        self.assertEqual(report["hidraw"], [])
        self.assertEqual(report["battery"], [])
        self.assertIn("unknown", report["secure_boot"])

    def test_collects_hardware_and_does_not_include_serial_or_credentials(self):
        self.write("etc/os-release", 'ID=fedora\nVERSION_ID=44\nPRETTY_NAME="Fedora Linux 44"\n')
        self.write("sys/class/dmi/id/product_name", "XWC-P\n")
        self.write("sys/class/hidraw/hidraw2/device/uevent", "HID_ID=0018:000027C6:00000F9A\nHID_NAME=Goodix Touchpad\nHID_UNIQ=private-serial\n")
        self.write("sys/class/hidraw/hidraw2/device/report_descriptor", b"\x05\x0d")
        self.write("proc/cmdline", "root=/dev/test password=secret i8042.dumbkbd=1 quiet")
        self.write("sys/class/power_supply/BAT1/type", "Battery")
        self.write("sys/class/power_supply/BAT1/charge_control_end_threshold", "80")
        report = diagnose.collect(self.sys, self.proc, self.etc)
        self.assertEqual(report["system"]["distribution"]["VERSION_ID"], "44")
        self.assertEqual(report["hidraw"][0]["descriptor_bytes"], 2)
        self.assertEqual(report["hidraw"][0]["HID_NAME"], "Goodix Touchpad")
        self.assertEqual(report["battery"][0]["name"], "BAT1")
        self.assertEqual(report["keyboard_parameters"], ["i8042.dumbkbd=1"])
        self.assertNotIn("private-serial", str(report))
        self.assertNotIn("password", str(report))

    def test_acpi_identity_and_checksum(self):
        path = self.write("sys/firmware/acpi/tables/SSDT7", bytes(table()))
        self.assertTrue(diagnose.acpi_header(path)["valid"])
        self.assertEqual(diagnose.collect(self.sys, self.proc, self.etc)["acpi"][0]["oem_table_id"], "I2C_DEVT")
        path.write_bytes(path.read_bytes() + b"wrong-length")
        self.assertFalse(diagnose.acpi_header(path)["valid"])

    def test_secure_boot_payload_follows_efi_attributes(self):
        path = self.write("sys/firmware/efi/efivars/SecureBoot-test", b"\x07\x00\x00\x00\x01")
        self.assertEqual(diagnose.secure_boot(self.sys), "enabled")
        path.write_bytes(b"\x07\x00\x00\x00\x00")
        self.assertEqual(diagnose.secure_boot(self.sys), "disabled")


if __name__ == "__main__":
    unittest.main()
