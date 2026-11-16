"""Hardware-free regression tests for discovery and settings failure paths."""

import contextlib
import importlib.util
import io
from pathlib import Path
import stat
import tempfile
import types
import unittest
from unittest import mock


SOURCE = Path(__file__).resolve().parents[1] / "touchBar/touchpad_control.py"
SPEC = importlib.util.spec_from_file_location("touchpad_control", SOURCE)
touchpad = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(touchpad)

# Report ID 6, eight bits per field, seven fields plus ID, Output(Data,Var,Abs).
OUTPUT_DESCRIPTOR = bytes.fromhex("85 06 75 08 95 07 91 02")


class ConfigTests(unittest.TestCase):
    def test_malformed_json_is_not_replaced_with_defaults(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "settings.json"
            path.write_text("{broken", encoding="utf-8")
            with self.assertRaises(touchpad.TouchpadError):
                touchpad.load_config(path)

    def test_wrong_types_and_out_of_range_preferences_are_rejected(self):
        for value in ([], {"sensitivity": True}, {"sensitivity": 8},
                      {"shock": "high"}, {"edge_brightness": 1}):
            with self.subTest(value=value), self.assertRaises(touchpad.TouchpadError):
                touchpad._validated_config(value)

    def test_atomic_replace_failure_preserves_previous_settings(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "settings.json"
            previous = '{"sensitivity": 0}'
            path.write_text(previous, encoding="utf-8")
            with mock.patch.object(touchpad.os, "replace", side_effect=PermissionError("denied")):
                with self.assertRaises(touchpad.TouchpadError):
                    touchpad.save_config(touchpad.DEFAULT_CONFIG, path)
            self.assertEqual(path.read_text(encoding="utf-8"), previous)
            self.assertEqual(list(Path(directory).iterdir()), [path])

    def test_roundtrip_fills_missing_fields_and_ignores_unknown_fields(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "nested/settings.json"
            touchpad.save_config({"sensitivity": 0, "unknown": 12}, path)
            self.assertEqual(touchpad.load_config(path), dict(touchpad.DEFAULT_CONFIG, sensitivity=0))


class DiscoveryTests(unittest.TestCase):
    def test_matching_requires_actual_i2c_vendor_and_product_id(self):
        self.assertTrue(touchpad._matching_hid_id("HID_ID=0018:000027c6:00000f9a\n"))
        for value in ("HID_ID=0003:000027c6:00006f94\n",  # fingerprint
                      "HID_ID=0003:000027c6:00000f9a\n",  # wrong transport
                      "HID_NAME=Goodix 27C6\n", "HID_ID=oops:27c6:0f9a\n"):
            with self.subTest(value=value):
                self.assertFalse(touchpad._matching_hid_id(value))

    def test_discovery_ignores_fingerprint_and_missing_node(self):
        with tempfile.TemporaryDirectory() as directory:
            sysfs = Path(directory) / "sys"
            dev_root = Path(directory) / "dev"
            for name, hid_id in (("hidraw0", "0003:000027C6:00006F94"),
                                 ("hidraw1", "0018:000027C6:00000F9A"),
                                 ("hidraw2", "0018:000027C6:00000F9A")):
                uevent = sysfs / name / "device/uevent"
                uevent.parent.mkdir(parents=True)
                uevent.write_text(f"HID_ID={hid_id}\n", encoding="utf-8")
            original_stat = Path.stat

            def device_stat(path, *args, **kwargs):
                if path == dev_root / "hidraw1":
                    return types.SimpleNamespace(st_mode=stat.S_IFCHR)
                return original_stat(path, *args, **kwargs)

            with mock.patch.object(Path, "stat", device_stat):
                found = touchpad.discover_touchpads(sysfs, dev_root)
            self.assertEqual(found, [str(dev_root / "hidraw1")])

    @mock.patch.object(touchpad, "IS_WINDOWS", False)
    def test_ambiguous_nodes_require_explicit_selection(self):
        with mock.patch.object(touchpad, "discover_touchpads", return_value=["/dev/hidraw1", "/dev/hidraw2"]):
            with self.assertRaises(touchpad.TouchpadError):
                touchpad.find_touchpad_hidraw()
            self.assertEqual(touchpad.find_touchpad_hidraw("/dev/hidraw2"), "/dev/hidraw2")
            with self.assertRaises(touchpad.TouchpadError):
                touchpad.find_touchpad_hidraw("/dev/hidraw0")


class DescriptorTests(unittest.TestCase):
    def test_output_length_includes_id_and_multiple_output_fields(self):
        descriptor = bytes.fromhex("85 06 75 08 95 03 91 02 95 04 91 02")
        self.assertEqual(touchpad.output_report_size(descriptor, 6), 8)

    def test_same_id_input_or_feature_is_not_an_output_report(self):
        for main_item in ("81 02", "b1 02"):
            with self.subTest(main_item=main_item):
                descriptor = bytes.fromhex("85 06 75 08 95 07 " + main_item)
                self.assertIsNone(touchpad.output_report_size(descriptor, 6))

    def test_global_push_pop_restores_report_size_and_id(self):
        descriptor = bytes.fromhex("85 06 75 08 95 07 a4 85 07 95 01 91 02 b4 91 02")
        self.assertEqual(touchpad.output_report_size(descriptor, 6), 8)
        self.assertEqual(touchpad.output_report_size(descriptor, 7), 2)

    def test_malformed_descriptor_cannot_authorize_write(self):
        for value in (b"\x85", b"\xfe", b"\xfe\x04\x01\x01", b"\xb4", b"\xa4", b"\x85\x00"):
            with self.subTest(value=value), self.assertRaises(touchpad.TouchpadError):
                touchpad.output_report_size(value, 6)


@mock.patch.object(touchpad, "IS_WINDOWS", False)
class LinuxWriteTests(unittest.TestCase):
    def test_unverified_protocol_does_not_open_device_without_opt_in(self):
        with mock.patch.object(touchpad, "find_touchpad_hidraw", return_value="/dev/hidraw1"), \
                mock.patch.object(touchpad.os, "open") as open_device:
            with self.assertRaisesRegex(touchpad.TouchpadError, "unverified"):
                touchpad.apply_settings("/dev/hidraw1", 2, 3)
            open_device.assert_not_called()

    def test_incompatible_descriptor_does_not_open_device(self):
        with mock.patch.object(touchpad, "find_touchpad_hidraw", return_value="/dev/hidraw1"), \
                mock.patch.object(Path, "read_bytes", return_value=bytes.fromhex("85 06 75 08 95 07 b1 02")), \
                mock.patch.object(touchpad.os, "open") as open_device:
            with self.assertRaisesRegex(touchpad.TouchpadError, "feature report"):
                touchpad.apply_settings("/dev/hidraw1", 2, 3, experimental=True)
            open_device.assert_not_called()

    def test_short_write_fails_and_closes_descriptor(self):
        with mock.patch.object(touchpad, "find_touchpad_hidraw", return_value="/dev/hidraw1"), \
                mock.patch.object(Path, "read_bytes", return_value=OUTPUT_DESCRIPTOR), \
                mock.patch.object(touchpad.os, "open", return_value=12), \
                mock.patch.object(touchpad.os, "fstat", return_value=types.SimpleNamespace(st_mode=stat.S_IFCHR)), \
                mock.patch.object(touchpad.os, "write", return_value=3), \
                mock.patch.object(touchpad.os, "close") as close_device:
            with self.assertRaisesRegex(touchpad.TouchpadError, "Short HID write"):
                touchpad.apply_settings("/dev/hidraw1", 2, 3, experimental=True)
            close_device.assert_called_once_with(12)

    def test_permission_failure_has_actionable_error(self):
        with mock.patch.object(touchpad, "find_touchpad_hidraw", return_value="/dev/hidraw1"), \
                mock.patch.object(Path, "read_bytes", return_value=OUTPUT_DESCRIPTOR), \
                mock.patch.object(touchpad.os, "open", side_effect=PermissionError()):
            with self.assertRaisesRegex(touchpad.TouchpadError, "udev"):
                touchpad.apply_settings("/dev/hidraw1", 2, 3, experimental=True)


@mock.patch.object(touchpad, "IS_WINDOWS", False)
class CliTests(unittest.TestCase):
    def test_failed_application_returns_nonzero_and_preserves_settings(self):
        with mock.patch.object(touchpad, "find_touchpad_hidraw", return_value="/dev/hidraw1"), \
                mock.patch.object(touchpad, "load_config", return_value=touchpad.DEFAULT_CONFIG.copy()), \
                mock.patch.object(touchpad, "apply_settings", side_effect=touchpad.TouchpadError("no access")), \
                mock.patch.object(touchpad, "save_config") as save, \
                contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(touchpad.main(["--sensitivity", "low"]), 1)
            save.assert_not_called()

    def test_apply_saved_without_file_does_not_send_defaults(self):
        with tempfile.TemporaryDirectory() as directory, \
                mock.patch.object(touchpad, "find_touchpad_hidraw", return_value="/dev/hidraw1"), \
                mock.patch.object(touchpad, "apply_settings") as apply, \
                contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(touchpad.main(["--apply-saved", "--config", str(Path(directory) / "missing")]), 1)
            apply.assert_not_called()

    def test_status_distinguishes_saved_preferences_from_readback(self):
        output = io.StringIO()
        with tempfile.TemporaryDirectory() as directory, \
                mock.patch.object(touchpad, "find_touchpad_hidraw", return_value=None), \
                contextlib.redirect_stdout(output):
            result = touchpad.main(["--status", "--config", str(Path(directory) / "missing")])
        self.assertEqual(result, 1)
        self.assertIn("not hardware readback", output.getvalue())
        self.assertIn("unverified", output.getvalue())


class WindowsTests(unittest.TestCase):
    def test_official_string_registry_preferences_preserve_false_boolean(self):
        values = {"sensitivity": ("1", 1), "shock": ("2", 1),
                  "EdgeGestureAdjusBrightness": ("0", 1), "EdgeGestureAdjusVolume": ("1", 1)}
        registry = types.SimpleNamespace(
            HKEY_CURRENT_USER=1,
            OpenKey=mock.Mock(return_value=contextlib.nullcontext(12)),
            QueryValueEx=lambda key, name: values[name],
        )
        with tempfile.TemporaryDirectory() as directory, \
                mock.patch.object(touchpad, "IS_WINDOWS", True), \
                mock.patch.dict("sys.modules", {"winreg": registry}):
            cfg = touchpad.load_config(Path(directory) / "missing.json")
        self.assertEqual(cfg, {"sensitivity": 1, "shock": 2,
                               "edge_brightness": False, "edge_volume": True})

    def test_helper_wrappers_are_void_and_registry_types_are_preserved(self):
        helper = types.SimpleNamespace(**{name: mock.Mock() for name in (
            "ChangeSensitivityOpt", "ChangeShockOpt", "ChangeEdgeGestureAdjusBrightnessOpt")})
        values = {"sensitivity": ("1", 1), "shock": (2, 4),
                  "EdgeGestureAdjusBrightness": ("0", 1)}
        registry = types.SimpleNamespace(
            HKEY_CURRENT_USER=1, REG_SZ=1, REG_EXPAND_SZ=2, REG_DWORD=4,
            CreateKey=mock.Mock(return_value=contextlib.nullcontext(12)),
            QueryValueEx=lambda key, name: values[name], SetValueEx=mock.Mock(),
        )
        with mock.patch.object(touchpad, "IS_WINDOWS", True), \
                mock.patch.object(Path, "is_file", return_value=True), \
                mock.patch.object(touchpad, "_windows_service_running", return_value=True), \
                mock.patch.object(touchpad.os, "add_dll_directory", create=True,
                                  return_value=contextlib.nullcontext()), \
                mock.patch.object(touchpad.ctypes, "CDLL", return_value=helper), \
                mock.patch.dict("sys.modules", {"winreg": registry}):
            touchpad.apply_settings("Windows helper DLL", 2, 3, False)
        self.assertIsNone(helper.ChangeSensitivityOpt.restype)
        helper.ChangeSensitivityOpt.assert_called_once_with(2)
        registry.SetValueEx.assert_has_calls([
            mock.call(12, "sensitivity", 0, 1, "2"),
            mock.call(12, "shock", 0, 4, 3),
            mock.call(12, "EdgeGestureAdjusBrightness", 0, 1, "0"),
        ])

    def test_missing_helper_is_not_reported_as_hardware_success(self):
        with mock.patch.object(touchpad, "IS_WINDOWS", True), \
                mock.patch.object(Path, "is_file", return_value=False):
            with self.assertRaisesRegex(touchpad.TouchpadError, "Registry preferences alone"):
                touchpad.apply_settings("Windows helper DLL", 2, 3)

    def test_stopped_pc_manager_service_cannot_apply_settings(self):
        with mock.patch.object(touchpad, "IS_WINDOWS", True), \
                mock.patch.object(Path, "is_file", return_value=True), \
                mock.patch.object(touchpad, "_windows_service_running", return_value=False):
            with self.assertRaisesRegex(touchpad.TouchpadError, "MBAMainService"):
                touchpad.apply_settings("Windows helper DLL", 2, 3)

    def test_windows_status_reports_ipc_service_and_absence(self):
        output = io.StringIO()
        with mock.patch.object(touchpad, "IS_WINDOWS", True), \
                mock.patch.object(touchpad, "load_config", return_value=touchpad.DEFAULT_CONFIG.copy()), \
                mock.patch.object(Path, "is_file", return_value=False), \
                mock.patch.object(touchpad, "_windows_service_running", return_value=False), \
                contextlib.redirect_stdout(output):
            self.assertEqual(touchpad.main(["--status"]), 1)
        self.assertIn("IPC requests", output.getvalue())
        self.assertIn("not running", output.getvalue())


if __name__ == "__main__":
    unittest.main()
