#!/usr/bin/env bash
# Build the narrowly scoped workaround from this machine's current firmware.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
original=""
output="$HERE/build"
tables_dir=/sys/firmware/acpi/tables
external_tables=()
usage() {
    cat <<'EOF'
Usage: bash touchBar/build.sh [--original-table FILE] [--output-dir DIR]
                            [--external-table FILE ...] [--help]
Requires Python 3, iasl (acpica-tools/acpica), and cpio.
By default, reads the HONOR I2C_DEVT SSDT from the running Linux firmware.
Only the known NFC0 module-level INT1 assignment is patched. Unknown firmware
layouts fail without producing an installable bundle. The repository's old
precompiled table is a reference and is never used as an installation source.
Use --external-table repeatedly if iasl needs other ACPI tables to resolve
external method signatures. Run as root when firmware tables are unreadable.
EOF
}
while (($#)); do
    case "$1" in
        --original-table|--output-dir|--external-table)
            [[ $# -ge 2 && -n $2 ]] || { echo "Missing value for $1" >&2; exit 2; }
            case "$1" in
                --original-table) original=$2 ;;
                --output-dir) output=$2 ;;
                --external-table) external_tables+=("$2") ;;
            esac
            shift 2 ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done
for dependency in python3 iasl cpio; do
    command -v "$dependency" >/dev/null || { echo "Missing dependency: $dependency" >&2; exit 1; }
done
[[ ! -e $output ]] || { echo "Output already exists: $output (choose a new directory)" >&2; exit 1; }
if [[ -z $original ]]; then
    original="$(python3 "$HERE/acpi_override.py" find "$tables_dir")"
fi
[[ -r $original ]] || { echo "Cannot read firmware table: $original" >&2; exit 1; }
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
cp -- "$original" "$tmp/original.aml"
decompile=(iasl)
if ((${#external_tables[@]})); then
    decompile+=(-e "${external_tables[@]}")
fi
decompile+=(-d "$tmp/original.aml")
if ! "${decompile[@]}" >"$tmp/decompile.log" 2>&1; then
    cat "$tmp/decompile.log" >&2
    exit 1
fi
python3 "$HERE/acpi_override.py" patch "$tmp/original.aml" "$tmp/original.dsl" "$tmp/patched.dsl"
if ! iasl -p "$tmp/patched" "$tmp/patched.dsl" >"$tmp/compile.log" 2>&1; then
    cat "$tmp/compile.log" >&2
    echo "Compilation failed. If method argument counts are unresolved, supply the firmware's external tables." >&2
    exit 1
fi
python3 "$HERE/acpi_override.py" manifest "$tmp/original.aml" "$tmp/patched.aml" "$tmp/manifest.json"
mkdir -p "$tmp/package/kernel/firmware/acpi"
cp "$tmp/patched.aml" "$tmp/package/kernel/firmware/acpi/ssdt-touchpad.aml"
(cd "$tmp/package" && find kernel -print0 | cpio --null -H newc -o --quiet) > "$tmp/acpi-touchpad-override.img"
mkdir -p -- "$output"
install -m 0644 "$tmp/original.aml" "$output/original.aml"
install -m 0644 "$tmp/original.dsl" "$output/original.dsl"
install -m 0644 "$tmp/patched.aml" "$output/ssdt-touchpad.aml"
install -m 0644 "$tmp/patched.dsl" "$output/ssdt-touchpad.dsl"
install -m 0644 "$tmp/manifest.json" "$output/manifest.json"
install -m 0644 "$tmp/acpi-touchpad-override.img" "$output/acpi-touchpad-override.img"
echo "Built firmware-specific bundle: $output"
echo "Review ssdt-touchpad.dsl before installing: sudo bash touchBar/install.sh --acpi-dir '$output'"
