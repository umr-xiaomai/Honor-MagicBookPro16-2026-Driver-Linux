import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import unittest


MODULE_PATH = Path(__file__).resolve().parents[1] / "touchBar" / "acpi_override.py"
SPEC = importlib.util.spec_from_file_location("acpi_override", MODULE_PATH)
acpi = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(acpi)


def firmware_table(revision=0x1000, table_id=b"I2C_DEVT", payload=b"\x00"):
    data = bytearray(struct.pack("<4sIBB6s8sI4sI", b"SSDT", 36 + len(payload),
                                 2, 0, b"HONOR ", table_id, revision, b"INTL", 1) + payload)
    data[9] = -sum(data) % 256
    return bytes(data)


SOURCE = '''DefinitionBlock ("", "SSDT", 2, "HONOR", "I2C_DEVT", 0x00001000)
{
    Device (NFC0)
    {
        CreateWordField (SBGF, 0x17, INT1)
        INT1 = GNUM (0x001A088A)
        Method (_STA, 0, NotSerialized) { Return (Zero) }
        Method (_CRS, 0, NotSerialized)
        {
            Return (ConcatenateResTemplate (SBFU, SBGF))
        }
    }
}
'''


class AcpiPatchTests(unittest.TestCase):
    def test_dracut_other_table_directory_is_protected(self):
        for relative in ("etc/dracut.conf", "etc/dracut.conf.d/10-other-acpi.conf",
                         "usr/lib/dracut/dracut.conf.d/10-vendor-acpi.conf"):
            with self.subTest(relative=relative), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                config = root / relative
                config.parent.mkdir(parents=True, exist_ok=True)
                config.write_text('export acpi_table_dir="/existing/acpi"\n', encoding="utf-8")
                with self.assertRaisesRegex(ValueError, "Manually merge"):
                    acpi.check_dracut_configs(root)

    def test_dracut_comments_and_own_config_are_allowed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            configs = root / "etc/dracut.conf.d"
            configs.mkdir(parents=True)
            (root / "etc/dracut.conf").write_text('# acpi_table_dir="/comment"\n', encoding="utf-8")
            (configs / "90-honor-touchpad-acpi.conf").write_text('acpi_table_dir="/usr/local/share/honor-touchpad/acpi"\n', encoding="utf-8")
            acpi.check_dracut_configs(root)
            (configs / "91-another.conf").write_text('acpi_table_dir+="/another"\n', encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "Existing acpi_table_dir"):
                acpi.check_dracut_configs(root)

    def test_dracut_etc_snippet_shadows_same_named_vendor_snippet(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            vendor = root / "usr/lib/dracut/dracut.conf.d/10-acpi.conf"
            override = root / "etc/dracut.conf.d/10-acpi.conf"
            for path in (vendor, override):
                path.parent.mkdir(parents=True)
            vendor.write_text('acpi_table_dir="/inactive"\n', encoding="utf-8")
            override.write_text('# disabled by local configuration\n', encoding="utf-8")
            acpi.check_dracut_configs(root)

    def test_patch_retains_identity_and_moves_only_known_operation(self):
        result = acpi.patch_asl(SOURCE, firmware_table())
        self.assertIn('"I2C_DEVT", 0x00001001', result)
        self.assertEqual(result.count("INT1 = GNUM"), 1)
        self.assertGreater(result.index("INT1 = GNUM"), result.index("Method (_CRS"))
        self.assertIn("Method (_STA, 0, NotSerialized) { Return (Zero) }", result)

    def test_already_patched_firmware_refused(self):
        patched = acpi.patch_asl(SOURCE, firmware_table())
        with self.assertRaisesRegex(ValueError, "already scoped"):
            acpi.patch_asl(patched, firmware_table(0x1001))

    def test_unknown_firmware_crs_is_refused(self):
        with self.assertRaisesRegex(ValueError, "_CRS differs"):
            acpi.patch_asl(SOURCE.replace("Return (Concatenate", "Store (One, X)\n Return (Concatenate"), firmware_table())

    def test_comments_do_not_create_extra_devices_or_assignments(self):
        comment = '// Device (NFC0) { INT1 = GNUM (0x001A088A) }\n'
        self.assertIn("0x00001001", acpi.patch_asl(comment + SOURCE, firmware_table()))

    def test_source_revision_must_match_original(self):
        with self.assertRaisesRegex(ValueError, "identity/revision"):
            acpi.patch_asl(SOURCE, firmware_table(0x2000))

    def test_old_prebuilt_wrong_identity_refused(self):
        with self.assertRaisesRegex(ValueError, "I2C_DEVT"):
            acpi.make_manifest(firmware_table(), firmware_table(0x1001, b"I2CDEVC "))

    def test_non_increasing_revision_refused(self):
        with self.assertRaisesRegex(ValueError, "revision"):
            acpi.make_manifest(firmware_table(), firmware_table())

    def test_checksum_damage_refused(self):
        damaged = bytearray(firmware_table())
        damaged[-1] ^= 1
        with self.assertRaisesRegex(ValueError, "checksum"):
            acpi.table_header(damaged)

    def test_bundle_binds_to_exact_live_firmware(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle = Path(directory) / "bundle"
            tables = Path(directory) / "tables"
            bundle.mkdir()
            tables.mkdir()
            original, patched = firmware_table(), firmware_table(0x1001)
            (bundle / "original.aml").write_bytes(original)
            (bundle / "ssdt-touchpad.aml").write_bytes(patched)
            manifest = acpi.make_manifest(original, patched)
            (bundle / "manifest.json").write_text(json.dumps(manifest), encoding="utf-8")
            (tables / "SSDT27").write_bytes(original)
            self.assertEqual(acpi.validate_bundle(bundle, tables), manifest)
            # Same identity and OEM revision, different firmware content.
            (tables / "SSDT27").write_bytes(firmware_table(payload=b"\x01"))
            with self.assertRaisesRegex(ValueError, "current firmware"):
                acpi.validate_bundle(bundle, tables)

    def test_modified_bundle_cannot_use_stale_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle = Path(directory)
            original = firmware_table()
            patched = firmware_table(0x1001)
            (bundle / "original.aml").write_bytes(original)
            (bundle / "ssdt-touchpad.aml").write_bytes(firmware_table(0x1001, payload=b"\x05"))
            (bundle / "manifest.json").write_text(json.dumps(acpi.make_manifest(original, patched)), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "manifest"):
                acpi.validate_bundle(bundle, bundle)

    def test_exact_patched_table_reinstall_requires_matching_bios_identity(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle = Path(directory) / "bundle"
            tables = Path(directory) / "tables"
            dmi = Path(directory) / "dmi"
            for path in (bundle, tables, dmi):
                path.mkdir()
            original, patched = firmware_table(), firmware_table(0x1001)
            (bundle / "original.aml").write_bytes(original)
            (bundle / "ssdt-touchpad.aml").write_bytes(patched)
            (tables / "SSDT27").write_bytes(patched)
            manifest = acpi.make_manifest(original, patched)
            (bundle / "manifest.json").write_text(json.dumps(manifest), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "current firmware"):
                acpi.validate_bundle(bundle, tables, dmi)
            for name in acpi.FIRMWARE_ID_FIELDS:
                (dmi / name).write_text("fixture-" + name, encoding="utf-8")
            manifest["firmware_identity"] = acpi.firmware_identity(dmi)
            (bundle / "manifest.json").write_text(json.dumps(manifest), encoding="utf-8")
            self.assertEqual(acpi.validate_bundle(bundle, tables, dmi), manifest)
            (dmi / "bios_version").write_text("new-version", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "current firmware"):
                acpi.validate_bundle(bundle, tables, dmi)


if __name__ == "__main__":
    unittest.main()
