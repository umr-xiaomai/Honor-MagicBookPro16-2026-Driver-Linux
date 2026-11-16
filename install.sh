#!/usr/bin/env bash
# Install detected functionality. Boot changes are explicit module options.
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODULES=(touchBar keyBoard audioCodec fingerPrint batteryCharge)
selected=()
module_args=()
dry_run=false
diagnose=false

usage() {
    cat <<'EOF'
Usage: bash install.sh [--dry-run] [--module NAME ...] [-- MODULE_OPTIONS]
       bash install.sh --diagnose [-- DIAGNOSTIC_OPTIONS]

Modules: touchBar keyBoard audioCodec fingerPrint batteryCharge
With no --module, run all modules with their conservative defaults.
Use -- before options for exactly one selected module, for example:
  sudo bash install.sh --module touchBar -- --acpi-dir /path/to/generated
  sudo bash install.sh --module keyBoard -- --enable-dumbkbd
  bash install.sh --diagnose -- --json

--dry-run   Show the plan without root privileges or system changes.
--diagnose  Collect a read-only Linux hardware report; no installation.
--help      Show this help.
EOF
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
while (($#)); do
    case "$1" in
        --help|-h) usage; exit 0 ;;
        --dry-run) dry_run=true; shift ;;
        --diagnose) diagnose=true; shift ;;
        --module)
            (($# >= 2)) || die '--module requires a name'
            case "$2" in
                touchBar|keyBoard|audioCodec|fingerPrint|batteryCharge) ;;
                *) die "Unknown module: $2" ;;
            esac
            for name in "${selected[@]}"; do
                [[ "$name" != "$2" ]] || die "Duplicate module: $2"
            done
            selected+=("$2"); shift 2 ;;
        --) shift; module_args=("$@"); break ;;
        *) die "Unknown argument: $1 (see --help)" ;;
    esac
done

if $diagnose; then
    ((${#selected[@]} == 0)) || die '--diagnose cannot be combined with --module'
    $dry_run && die '--diagnose is already read-only; omit --dry-run'
    command -v python3 >/dev/null 2>&1 || die 'python3 is required for diagnostics'
    exec python3 "$ROOT_DIR/tools/honor_diagnose.py" "${module_args[@]}"
fi

((${#module_args[@]} == 0 || ${#selected[@]} == 1)) || die 'Module options require exactly one --module'
if ((${#selected[@]} == 0)); then selected=("${MODULES[@]}"); fi

# Plans also work on developer workstations; installation requires real Linux.
if ! $dry_run; then
    [[ "$(uname -s)" == Linux ]] || die 'Installation requires a booted Linux system'
    [[ "$(id -u)" == 0 ]] || die 'Run installation with sudo; --dry-run needs no root'
    [[ -r /sys/class/dmi/id/sys_vendor && -r /sys/class/dmi/id/product_name ]] || die 'DMI information unavailable'
    vendor="$(cat /sys/class/dmi/id/sys_vendor)"
    product="$(cat /sys/class/dmi/id/product_name)"
    [[ "${vendor^^}" == *HONOR* && "$product" == XWC-P ]] || die "Unsupported hardware: $vendor $product (expected HONOR XWC-P)"
fi

printf 'HONOR XWC-P setup%s\n' "$(if $dry_run; then printf ' (dry run)'; fi)"
printf 'Boot changes require explicit module options. No packages are installed automatically.\n'
for module in "${selected[@]}"; do
    script="$ROOT_DIR/$module/install.sh"
    [[ -f "$script" ]] || die "Missing installer: $script"
    args=()
    if $dry_run; then args+=(--dry-run); fi
    printf '\n[%s]\n' "$module"
    if bash "$script" "${args[@]}" "${module_args[@]}"; then
        printf '[%s] completed; review module output for unavailable hardware/functions.\n' "$module"
    else
        result=$?
        printf '[%s] failed (exit %s). Previous modules may already be installed.\n' "$module" "$result" >&2
        exit "$result"
    fi
done
printf '\nSetup finished. Use --diagnose to inspect actual device state.\n'
