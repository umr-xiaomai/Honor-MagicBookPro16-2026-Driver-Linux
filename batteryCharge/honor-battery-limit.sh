#!/usr/bin/env bash
# Use only kernel-exported charge thresholds; never guess vendor EC commands.
set -euo pipefail
SYSFS_ROOT=/sys
BATTERY=
LIMIT=
STATUS=0
usage() {
    cat <<'EOF'
Usage: honor-battery-limit [--status] [--battery NAME] [LIMIT]
       honor-battery-limit [--sysfs-root DIRECTORY] [--battery NAME] [LIMIT]
With no LIMIT, display exported thresholds. LIMIT must be an integer 1..100;
the kernel/firmware may restrict the available range further.
--sysfs-root is intended for offline diagnostics and hardware-free tests.
Exit status 3 means no supported charge-threshold interface was found.
EOF
}
while (( $# )); do
    case "$1" in
        --status) STATUS=1; shift ;;
        --sysfs-root|--battery)
            (( $# >= 2 )) || { echo "Missing value for $1" >&2; exit 2; }
            if [[ $1 == --sysfs-root ]]; then SYSFS_ROOT=$2; else BATTERY=$2; fi
            shift 2 ;;
        -h|--help) usage; exit 0 ;;
        --*) echo "Unknown option: $1" >&2; exit 2 ;;
        *)
            [[ -z $LIMIT ]] || { echo 'Specify only one limit.' >&2; exit 2; }
            LIMIT=$1; shift ;;
    esac
done
[[ -z $BATTERY || $BATTERY =~ ^[A-Za-z0-9_.-]+$ ]] || { echo 'Invalid battery name.' >&2; exit 2; }
if [[ -n $LIMIT ]]; then
    [[ $LIMIT =~ ^[0-9]{1,3}$ ]] || { echo 'LIMIT must be an integer 1..100.' >&2; exit 2; }
    LIMIT=$((10#$LIMIT))
    (( LIMIT >= 1 && LIMIT <= 100 )) || { echo 'LIMIT must be in 1..100.' >&2; exit 2; }
    (( ! STATUS )) || { echo '--status cannot be combined with a limit.' >&2; exit 2; }
fi
[[ -d $SYSFS_ROOT ]] || { echo "Missing sysfs directory: $SYSFS_ROOT" >&2; exit 1; }
SYSFS_ROOT="${SYSFS_ROOT%/}"
END_PATHS=()
START_PATHS=()
LABELS=()
shopt -s nullglob
for device in "$SYSFS_ROOT"/class/power_supply/*; do
    [[ -z $BATTERY || ${device##*/} == "$BATTERY" ]] || continue
    [[ -r $device/type && $(cat "$device/type") == Battery ]] || continue
    [[ -f $device/charge_control_end_threshold ]] || continue
    END_PATHS+=("$device/charge_control_end_threshold")
    START_PATHS+=("$device/charge_control_start_threshold")
    LABELS+=("${device##*/}")
done
WMI_PATH=
if (( ! ${#END_PATHS[@]} )) && [[ -z $BATTERY ]]; then
    for driver in huawei-wmi honor-wmi; do
        candidate="$SYSFS_ROOT/devices/platform/$driver/charge_control_thresholds"
        if [[ -f $candidate ]]; then WMI_PATH=$candidate; break; fi
    done
fi
if (( ! ${#END_PATHS[@]} )) && [[ -z $WMI_PATH ]]; then
    echo 'No supported charge-threshold interface. A compatible kernel driver is required.' >&2
    exit 3
fi
if [[ -z $LIMIT ]]; then
    for i in "${!END_PATHS[@]}"; do
        printf '%s: end=%s' "${LABELS[i]}" "$(cat "${END_PATHS[i]}")"
        [[ ! -f ${START_PATHS[i]} ]] || printf ' start=%s' "$(cat "${START_PATHS[i]}")"
        printf '\n'
    done
    [[ -z $WMI_PATH ]] || printf '%s: %s\n' "$WMI_PATH" "$(cat "$WMI_PATH")"
    exit 0
fi
# Alternate roots write only the caller's own fixture files. Actual sysfs
# permissions remain enforced by the kernel regardless of this check.
if [[ $SYSFS_ROOT == /sys ]] && (( EUID != 0 )); then
    echo 'Changing hardware thresholds requires sudo.' >&2; exit 1
fi
for i in "${!END_PATHS[@]}"; do
    [[ -w ${END_PATHS[i]} ]] || { echo "Threshold is not writable: ${END_PATHS[i]}" >&2; exit 1; }
    if [[ -f ${START_PATHS[i]} ]]; then
        current_start=$(cat "${START_PATHS[i]}")
        [[ $current_start =~ ^[0-9]{1,3}$ ]] || { echo 'Invalid current start threshold.' >&2; exit 1; }
        if (( 10#$current_start > LIMIT )); then
            [[ -w ${START_PATHS[i]} ]] || { echo 'Start threshold must also be writable to lower the limit.' >&2; exit 1; }
        fi
    fi
done
for i in "${!END_PATHS[@]}"; do
    if [[ -f ${START_PATHS[i]} ]]; then
        current_start=$(cat "${START_PATHS[i]}")
        if (( 10#$current_start > LIMIT )); then
            # Lower start first so the kernel never sees start > end.
            new_start=$(( LIMIT > 5 ? LIMIT - 5 : 0 ))
            printf '%s\n' "$new_start" > "${START_PATHS[i]}"
        fi
    fi
    printf '%s\n' "$LIMIT" > "${END_PATHS[i]}"
    actual=$(cat "${END_PATHS[i]}")
    [[ $actual == "$LIMIT" ]] || { echo "Firmware did not accept $LIMIT for ${LABELS[i]} (read back $actual)." >&2; exit 1; }
    echo "${LABELS[i]}: charge end threshold set to $LIMIT%"
done
if [[ -n $WMI_PATH ]]; then
    [[ -w $WMI_PATH ]] || { echo "Threshold is not writable: $WMI_PATH" >&2; exit 1; }
    new_start=$(( LIMIT > 5 ? LIMIT - 5 : 0 ))
    printf '%s %s\n' "$new_start" "$LIMIT" > "$WMI_PATH"
    read -r actual_start actual_end < "$WMI_PATH"
    [[ $actual_start == "$new_start" && $actual_end == "$LIMIT" ]] || {
        echo 'Firmware did not accept the requested WMI thresholds.' >&2; exit 1;
    }
    echo "WMI: charge thresholds set to $new_start-$LIMIT%"
fi
