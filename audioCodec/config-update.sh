#!/usr/bin/env bash
# Apply/remove a modprobe configuration and restore it if initramfs fails.
honor_audio_update_config() (
    set -euo pipefail
    local target=$1 replacement=$2
    shift 2
    (( $# )) || { echo 'An initramfs generator command is required.' >&2; exit 2; }
    local backup='' pending=0
    if [[ -e $target || -L $target ]]; then
        backup="$target.honor-backup.$(date +%Y%m%d%H%M%S).$$"
        cp -a -- "$target" "$backup"
        echo "Backup: $backup"
    fi
    # shellcheck disable=SC2329 # Invoked by the EXIT trap.
    cleanup_audio_config() {
        local status=$?
        set +e
        if (( pending )); then
            rm -f -- "$target"
            if [[ -n $backup ]] && ! cp -a -- "$backup" "$target"; then
                echo "RESTORE FAILED: restore audio config from $backup." >&2
            else
                echo 'Initramfs generation failed; the previous audio configuration was restored.' >&2
            fi
            echo 'Some initramfs images may already have changed; regenerate them with the restored configuration before rebooting.' >&2
        fi
        return "$status"
    }
    trap cleanup_audio_config EXIT
    pending=1
    rm -f -- "$target"
    if [[ -n $replacement ]]; then
        install -m 0644 "$replacement" "$target"
    fi
    "$@"
    pending=0
)
