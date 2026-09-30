#!/usr/bin/env bash
#
# HONOR Battery Charge Limit Script (70% / 80% / 100%)
# Supports sysfs charge_control_end_threshold and huawei-wmi charge_control_thresholds
#
set -euo pipefail

LIMIT="${1:-80}"

# 1. Standard Linux kernel power_supply threshold
BAT_THRESH="/sys/class/power_supply/BAT0/charge_control_end_threshold"
if [ -f "$BAT_THRESH" ]; then
    echo "$LIMIT" > "$BAT_THRESH"
    echo "Set BAT0 charge_control_end_threshold to $LIMIT%"
    exit 0
fi

# 2. huawei-wmi / honor-wmi threshold (format: start_threshold end_threshold)
WMI_THRESH="/sys/devices/platform/huawei-wmi/charge_control_thresholds"
if [ -f "$WMI_THRESH" ]; then
    START=$(( LIMIT > 10 ? LIMIT - 5 : LIMIT ))
    echo "$START $LIMIT" > "$WMI_THRESH"
    echo "Set huawei-wmi charge_control_thresholds to $START-$LIMIT%"
    exit 0
fi

echo "Warning: Battery charge threshold interface not available on this kernel."
