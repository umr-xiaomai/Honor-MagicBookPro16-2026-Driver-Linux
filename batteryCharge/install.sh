#!/usr/bin/env bash
# Install the tool; changing thresholds and enabling the service are opt-in.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
ENABLE=0
LIMIT=80
usage() {
    cat <<'EOF'
Usage: bash batteryCharge/install.sh [--dry-run] [--enable [--limit PERCENT]]
Default installs honor-battery-limit and a service without changing enablement.
--enable applies the limit and enables it at boot, only if supported by sysfs.
--limit requires --enable. No kernel interface is treated as unsupported.
EOF
}
LIMIT_GIVEN=0
while (( $# )); do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        --enable) ENABLE=1; shift ;;
        --limit)
            (( $# >= 2 )) || { echo 'Missing --limit value.' >&2; exit 2; }
            LIMIT=$2; LIMIT_GIVEN=1; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done
(( ! LIMIT_GIVEN || ENABLE )) || { echo '--limit requires --enable.' >&2; exit 2; }
if [[ ! $LIMIT =~ ^[0-9]{1,3}$ ]] || (( 10#$LIMIT < 1 || 10#$LIMIT > 100 )); then
    echo 'Limit must be an integer 1..100.' >&2; exit 2
fi
LIMIT=$((10#$LIMIT))
if (( DRY_RUN )); then
    echo '[dry-run] Install charge-limit CLI and service; leave existing enablement unchanged.'
    (( ! ENABLE )) || echo "[dry-run] Require a kernel threshold interface; set $LIMIT%; enable systemd service."
    exit 0
fi
[[ $(uname -s) == Linux ]] || { echo 'This installer requires Linux.' >&2; exit 1; }
(( EUID == 0 )) || { echo 'Run this installer with sudo.' >&2; exit 1; }
if (( ENABLE )); then
    if ! command -v systemctl >/dev/null || [[ ! -d /run/systemd/system ]]; then
        echo 'A running systemd system is required for --enable.' >&2; exit 1
    fi
    bash "$HERE/honor-battery-limit.sh" --status
fi
install -d /usr/local/bin /etc/systemd/system
install -m 0755 "$HERE/honor-battery-limit.sh" /usr/local/bin/honor-battery-limit
target=/etc/systemd/system/honor-battery-limit.service
if [[ -f $target ]] && ! cmp -s "$HERE/honor-battery-limit.service" "$target"; then
    cp -a "$target" "$target.bak.$(date +%s)"
fi
install -m 0644 "$HERE/honor-battery-limit.service" "$target"
if command -v systemctl >/dev/null && [[ -d /run/systemd/system ]]; then
    systemctl daemon-reload
fi
if (( ENABLE )); then
    /usr/local/bin/honor-battery-limit "$LIMIT"
    install -d /etc/default
    target=/etc/default/honor-battery-limit
    [[ ! -f $target ]] || cp -a "$target" "$target.bak.$(date +%s)"
    printf 'CHARGE_LIMIT=%s\n' "$LIMIT" > "$target"
    chmod 0644 "$target"
    systemctl enable honor-battery-limit.service
    echo "Charge limit $LIMIT% applied and enabled at boot."
else
    echo 'Battery CLI and service installed; existing service enablement is unchanged.'
    echo 'Check support with honor-battery-limit --status; use --enable to apply a persistent limit.'
fi
