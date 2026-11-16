"""Hardware-free checks for threshold discovery, validation and write ordering."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
BASH = os.environ.get("HONOR_TEST_BASH") or shutil.which("bash")
if not BASH and os.name == "nt":
    git = shutil.which("git")
    candidate = Path(git).parent.parent / "bin" / "bash.exe" if git else None
    if candidate and candidate.exists():
        BASH = str(candidate)


@unittest.skipUnless(BASH, "Bash is required to exercise the shell tool")
class BatteryLimitTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def battery(self, name, end="100", start=None, kind="Battery"):
        device = self.root / "class" / "power_supply" / name
        device.mkdir(parents=True)
        (device / "type").write_text(kind)
        if end is not None:
            (device / "charge_control_end_threshold").write_text(end)
        if start is not None:
            (device / "charge_control_start_threshold").write_text(start)
        return device

    def run_tool(self, *args):
        return subprocess.run(
            [BASH, str(REPO / "batteryCharge" / "honor-battery-limit.sh"),
             "--sysfs-root", self.root.as_posix(), *args],
            capture_output=True, text=True, timeout=10,
        )

    def test_discovers_battery_names_and_does_not_mutate_on_status(self):
        device = self.battery("BATT", start="20")
        result = self.run_tool()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("BATT: end=100 start=20", result.stdout)
        self.assertEqual((device / "charge_control_end_threshold").read_text(), "100")

    def test_changes_all_supported_batteries(self):
        first = self.battery("BAT1")
        second = self.battery("BATT")
        result = self.run_tool("80")
        self.assertEqual(result.returncode, 0, result.stderr)
        for device in (first, second):
            self.assertEqual((device / "charge_control_end_threshold").read_text().strip(), "80")

    def test_battery_selection_does_not_change_other_batteries(self):
        first = self.battery("BAT1")
        second = self.battery("BAT2")
        result = self.run_tool("--battery", "BAT2", "70")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((first / "charge_control_end_threshold").read_text(), "100")
        self.assertEqual((second / "charge_control_end_threshold").read_text().strip(), "70")

    def test_lowers_start_before_end_when_needed(self):
        device = self.battery("BAT1", start="90")
        result = self.run_tool("70")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((device / "charge_control_start_threshold").read_text().strip(), "65")
        self.assertEqual((device / "charge_control_end_threshold").read_text().strip(), "70")

    def test_preserves_compatible_start_threshold(self):
        device = self.battery("BAT1", start="20")
        result = self.run_tool("80")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((device / "charge_control_start_threshold").read_text(), "20")

    def test_prevalidates_all_start_thresholds_before_writing(self):
        first = self.battery("BAT1")
        self.battery("BAT2", start="invalid")
        result = self.run_tool("80")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((first / "charge_control_end_threshold").read_text(), "100")

    def test_rejects_invalid_limits_without_writing(self):
        device = self.battery("BAT1")
        for value in ("0", "101", "-1", "80.0", "abc", "80;echo bad", "80\\n70"):
            with self.subTest(value=value):
                result = self.run_tool(value)
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertEqual((device / "charge_control_end_threshold").read_text(), "100")

    def test_unknown_and_conflicting_options_fail(self):
        self.battery("BAT1")
        for args in (("--wat",), ("--status", "80"), ("--battery", "../BAT1", "80"), ("--battery",)):
            with self.subTest(args=args):
                self.assertEqual(self.run_tool(*args).returncode, 2)

    def test_unsupported_interface_is_not_success(self):
        self.battery("BAT1", end=None)
        result = self.run_tool("80")
        self.assertEqual(result.returncode, 3)
        self.assertIn("No supported", result.stderr)

    def test_nonbattery_supply_is_ignored(self):
        self.battery("AC", kind="Mains")
        self.assertEqual(self.run_tool("80").returncode, 3)

    def test_vendor_wmi_fallback_uses_start_end_pair(self):
        path = self.root / "devices" / "platform" / "huawei-wmi" / "charge_control_thresholds"
        path.parent.mkdir(parents=True)
        path.write_text("95 100")
        result = self.run_tool("80")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(path.read_text().strip(), "75 80")

    def test_standard_interface_takes_precedence_over_wmi(self):
        self.battery("BAT1")
        path = self.root / "devices" / "platform" / "huawei-wmi" / "charge_control_thresholds"
        path.parent.mkdir(parents=True)
        path.write_text("95 100")
        result = self.run_tool("80")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(path.read_text(), "95 100")


if __name__ == "__main__":
    unittest.main()
