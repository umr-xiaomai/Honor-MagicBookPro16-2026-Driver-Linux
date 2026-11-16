#!/usr/bin/env python3
"""Build-time guards for the narrowly scoped HONOR NFC0 ACPI workaround."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import sys


def table_header(data):
    if len(data) < 36:
        raise ValueError("ACPI table is shorter than its header")
    signature, length, revision, checksum, oem, table, version = struct.unpack_from(
        "<4sIBB6s8sI", data
    )
    if signature != b"SSDT" or length != len(data) or sum(data) % 256:
        raise ValueError("Expected a complete SSDT with a valid checksum")
    if oem.rstrip(b" \x00") != b"HONOR" or table.rstrip(b" \x00") != b"I2C_DEVT":
        raise ValueError("Only the HONOR I2C_DEVT SSDT is supported")
    return {"signature": signature.decode(), "oem_id": oem.decode(),
            "oem_table_id": table.decode(), "oem_revision": version,
            "revision": revision}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def without_comments(text):
    # Preserve offsets, quoted strings and newlines for the source transform.
    pattern = r'"(?:\\.|[^"\\])*"|/\*[\s\S]*?\*/|//[^\n]*'
    return re.sub(pattern, lambda m: m[0] if m[0].startswith('"') else
                  re.sub(r"[^\n]", " ", m[0]), text)


def block_end(text, opening):
    depth = 0
    for match in re.finditer(r'"(?:\\.|[^"\\])*"|[{}]', text[opening:]):
        if match[0] == "{":
            depth += 1
        elif match[0] == "}":
            depth -= 1
            if depth == 0:
                return opening + match.end()
    raise ValueError("Unbalanced ASL block")


def patch_asl(source, original):
    """Move exactly the known module-level NFC interrupt calculation to _CRS."""
    header = table_header(original)
    if header["oem_revision"] == 0xFFFFFFFF:
        raise ValueError("OEM revision cannot be incremented")
    clean = without_comments(source)
    devices = list(re.finditer(r"\bDevice\s*\(\s*NFC0\s*\)\s*\{", clean))
    if len(devices) != 1:
        raise ValueError("Expected exactly one NFC0 device; firmware layout unsupported")
    start = devices[0].end() - 1
    end = block_end(clean, start)
    device = clean[start:end]
    assignments = list(re.finditer(r"\bINT1\s*=\s*GNUM\s*\(\s*0x001A088A\s*\)", device))
    if len(assignments) != 1:
        raise ValueError("Known NFC0 interrupt assignment not found exactly once")
    assignment = assignments[0]
    prefix = re.sub(r'"(?:\\.|[^"\\])*"', '""', device[:assignment.start()])
    if prefix.count("{") - prefix.count("}") != 1:
        raise ValueError("NFC0 calculation is already scoped; no patch is needed")
    methods = list(re.finditer(r"\bMethod\s*\(\s*_CRS\s*,\s*0\s*,\s*NotSerialized\s*\)\s*\{", device))
    if len(methods) != 1:
        raise ValueError("Expected one NFC0 _CRS method")
    if assignment.start() >= methods[0].start():
        raise ValueError("NFC0 assignment order differs from the known firmware")
    if not re.search(r"\bCreateWordField\s*\(\s*SBGF\s*,\s*0x17\s*,\s*INT1\s*\)", device):
        raise ValueError("NFC0 INT1 resource field differs from the known firmware")
    method_end = block_end(device, methods[0].end() - 1)
    method = device[methods[0].end():method_end - 1]
    if not re.fullmatch(r"\s*Return\s*\(\s*ConcatenateResTemplate\s*\(\s*SBFU\s*,\s*SBGF\s*\)\s*\)\s*", method):
        raise ValueError("NFC0 _CRS differs from the known firmware")
    insertion = start + methods[0].end()
    output = source[:insertion] + "\n                INT1 = GNUM (0x001A088A)" + source[insertion:]
    begin, finish = start + assignment.start(), start + assignment.end()
    output = output[:begin] + output[finish:]
    definition = re.compile(r'(DefinitionBlock\s*\(\s*"[^"]*"\s*,\s*"SSDT"\s*,\s*\d+\s*,\s*"HONOR\s*"\s*,\s*"I2C_DEVT"\s*,\s*)(0x[0-9a-fA-F]+)(\s*\))')
    matches = list(definition.finditer(without_comments(output)))
    if len(matches) != 1 or int(matches[0][2], 16) != header["oem_revision"]:
        raise ValueError("ASL identity/revision does not match the original firmware table")
    match = matches[0]
    return output[:match.start(2)] + f'0x{header["oem_revision"] + 1:08X}' + output[match.end(2):]


def make_manifest(original, patched):
    before, after = table_header(original), table_header(patched)
    for key in ("signature", "oem_id", "oem_table_id", "revision"):
        if before[key] != after[key]:
            raise ValueError(f"Patched table changes {key}")
    if after["oem_revision"] != before["oem_revision"] + 1:
        raise ValueError("Patched OEM revision must be exactly original revision + 1")
    return {"format": 1, "original_sha256": digest(original),
            "patched_sha256": digest(patched), "original_header": before,
            "patched_header": after}


FIRMWARE_ID_FIELDS = ("sys_vendor", "product_name", "bios_vendor", "bios_version", "bios_date")


def firmware_identity(directory):
    identity = {}
    for name in FIRMWARE_ID_FIELDS:
        path = directory / name
        if not path.is_file():
            return {}
        identity[name] = path.read_text(encoding="utf-8").strip()
        if not identity[name]:
            return {}
    return identity


def check_dracut_configs(root=Path("/")):
    """Refuse to replace another workaround's global ACPI table directory."""
    # dracut uses /etc snippets in preference to same-named vendor snippets.
    snippets = {}
    for relative in ("usr/lib/dracut/dracut.conf.d", "etc/dracut.conf.d"):
        for path in sorted((root / relative).glob("*.conf")):
            snippets[path.name] = path
    own_config = root / "etc/dracut.conf.d/90-honor-touchpad-acpi.conf"
    paths = [root / "etc/dracut.conf", *snippets.values()]
    for path in paths:
        if path == own_config or not path.is_file():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            # Conservatively detect assignments, including exports/conditionals,
            # without executing arbitrary configuration shell commands.
            code = line.partition("#")[0]
            if re.search(r"\bacpi_table_dir\s*\+?=", code):
                raise ValueError(
                    f"Existing acpi_table_dir setting in {path}; automatic integration stopped. "
                    "Manually merge the validated AML into your existing ACPI table directory "
                    "and rebuild using that dracut configuration; do not replace the directory setting."
                )


def validate_bundle(directory, tables_directory, dmi_directory=Path("/sys/class/dmi/id")):
    original = (directory / "original.aml").read_bytes()
    patched = (directory / "ssdt-touchpad.aml").read_bytes()
    expected = make_manifest(original, patched)
    manifest = json.loads((directory / "manifest.json").read_text(encoding="utf-8"))
    if "firmware_identity" in manifest:
        identity = manifest["firmware_identity"]
        if (not isinstance(identity, dict) or (identity and
                (set(identity) != set(FIRMWARE_ID_FIELDS) or
                 any(not isinstance(value, str) or not value for value in identity.values())))):
            raise ValueError("Invalid firmware identity in manifest")
        expected["firmware_identity"] = identity
    if manifest != expected:
        raise ValueError("ACPI manifest hashes or metadata do not match the files")
    live_hashes = [digest(path.read_bytes()) for path in sorted(tables_directory.glob("SSDT*"))
                   if path.is_file()]
    if live_hashes.count(expected["original_sha256"]) == 1:
        return expected
    if (live_hashes.count(expected["patched_sha256"]) == 1
            and expected.get("firmware_identity")
            and expected["firmware_identity"] == firmware_identity(dmi_directory)):
        return expected
    else:
        raise ValueError("Original table does not match exactly one current firmware SSDT; rebuild on this BIOS")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    find = sub.add_parser("find")
    find.add_argument("directory", type=Path)
    patch = sub.add_parser("patch")
    patch.add_argument("original", type=Path)
    patch.add_argument("source", type=Path)
    patch.add_argument("output", type=Path)
    manifest = sub.add_parser("manifest")
    manifest.add_argument("original", type=Path)
    manifest.add_argument("patched", type=Path)
    manifest.add_argument("output", type=Path)
    validate = sub.add_parser("validate")
    validate.add_argument("directory", type=Path)
    validate.add_argument("--tables-dir", default=Path("/sys/firmware/acpi/tables"), type=Path)
    dracut = sub.add_parser("dracut-check", help="Check for another dracut ACPI table-directory setting")
    dracut.add_argument("--root-dir", type=Path, default=Path("/"))
    args = parser.parse_args(argv)
    try:
        if args.command == "find":
            matches = []
            for path in sorted(args.directory.glob("SSDT*")):
                try:
                    table_header(path.read_bytes())
                except ValueError:
                    continue
                matches.append(path)
            if len(matches) != 1:
                raise ValueError("Expected exactly one HONOR I2C_DEVT table in the firmware directory")
            print(matches[0])
        elif args.command == "patch":
            result = patch_asl(args.source.read_text(encoding="utf-8"), args.original.read_bytes())
            with args.output.open("w", encoding="utf-8", newline="\n") as output:
                output.write(result)
        elif args.command == "manifest":
            data = make_manifest(args.original.read_bytes(), args.patched.read_bytes())
            data["firmware_identity"] = firmware_identity(Path("/sys/class/dmi/id"))
            args.output.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
        elif args.command == "dracut-check":
            check_dracut_configs(args.root_dir)
        else:
            validate_bundle(args.directory, args.tables_dir)
            print("ACPI identity, revision, checksums and exact current firmware hash verified.")
    except (OSError, ValueError, struct.error) as error:
        parser.exit(1, f"ACPI validation failed: {error}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
