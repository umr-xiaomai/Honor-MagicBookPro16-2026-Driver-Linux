#!/usr/bin/env bash
# Sourceable helpers; callers supply paths so boot transactions can be tested.
honor_keyboard_stage_grub_config() {
    local source=$1 destination=$2
    [[ $source != "$destination" ]] || { echo 'Staging requires a separate destination.' >&2; return 2; }
    # Replace only our managed block, preserving other shell configuration.
    if ! awk '
        $0 == "# BEGIN HONOR XWC-P KEYBOARD WORKAROUND" {
            if (inside) exit 2
            inside = 1
            next
        }
        $0 == "# END HONOR XWC-P KEYBOARD WORKAROUND" {
            if (!inside) exit 2
            inside = 0
            next
        }
        !inside { print }
        END { if (inside) exit 2 }
    ' "$source" > "$destination"; then
        echo 'Malformed managed keyboard block; original GRUB config was preserved.' >&2
        return 1
    fi
    cat >> "$destination" <<'EOF'
# BEGIN HONOR XWC-P KEYBOARD WORKAROUND
case " ${GRUB_CMDLINE_LINUX:-} ${GRUB_CMDLINE_LINUX_DEFAULT:-} " in
    *' i8042.dumbkbd=1 '*) ;;
    *) GRUB_CMDLINE_LINUX="${GRUB_CMDLINE_LINUX:+$GRUB_CMDLINE_LINUX }i8042.dumbkbd=1" ;;
esac
# END HONOR XWC-P KEYBOARD WORKAROUND
EOF
}

honor_keyboard_apply_grub_workaround() (
    set -euo pipefail
    local config=$1
    shift
    (( $# )) || { echo 'A GRUB generator command is required.' >&2; exit 2; }
    local backup staged='' pending=0
    backup="$config.honor-backup.$(date +%Y%m%d%H%M%S).$$"
    cp -pL -- "$config" "$backup"
    echo "Backup: $backup"
    # shellcheck disable=SC2329 # Invoked by the EXIT trap.
    cleanup_keyboard_config() {
        local status=$?
        set +e
        if (( pending )); then
            if cat -- "$backup" > "$config"; then
                echo 'GRUB generation failed; the previous /etc/default/grub content was restored.' >&2
            else
                echo "RESTORE FAILED: restore the original config from $backup." >&2
            fi
            echo 'The generated GRUB menu may be incomplete; regenerate it successfully before rebooting.' >&2
        fi
        [[ -z $staged ]] || rm -f -- "$staged"
        return "$status"
    }
    trap cleanup_keyboard_config EXIT
    staged=$(mktemp "$config.honor-staged.XXXXXX")
    honor_keyboard_stage_grub_config "$config" "$staged"
    sh -n "$staged"
    pending=1
    cat -- "$staged" > "$config"
    "$@"
    pending=0
)
