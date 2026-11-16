#!/usr/bin/env bash
# Audio model overrides require a codec check and an explicit request.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=audioCodec/config-update.sh
source "$HERE/config-update.sh"
DRY_RUN=0
ENABLE_QUIRK=0
REMOVE_LEGACY=0
usage() {
    cat <<'EOF'
Usage: bash audioCodec/install.sh [--dry-run] [--enable-headset-quirk | --remove-legacy-config]
Default: inspect ALSA codecs without modifying audio configuration.
--enable-headset-quirk installs the experimental alc256-asus-mic model only
after detecting ALC256 on HONOR XWC-P. It is not a universal audio driver.
--remove-legacy-config backs up and removes this repository's old config.
EOF
}
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --enable-headset-quirk) ENABLE_QUIRK=1 ;;
        --remove-legacy-config) REMOVE_LEGACY=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $arg" >&2; usage >&2; exit 2 ;;
    esac
done
(( ! ENABLE_QUIRK || ! REMOVE_LEGACY )) || { usage >&2; exit 2; }
if (( DRY_RUN )); then
    echo '[dry-run] Inspect /proc/asound/card*/codec#*; no forced DSP/dmic options.'
    (( ! ENABLE_QUIRK )) || echo '[dry-run] Verify HONOR XWC-P and ALC256, then install experimental headset model.'
    (( ! REMOVE_LEGACY )) || echo '[dry-run] Back up and remove the recognized legacy ALSA config.'
    exit 0
fi
[[ $(uname -s) == Linux ]] || { echo 'This installer requires Linux.' >&2; exit 1; }
shopt -s nullglob
codecs=(/proc/asound/card*/codec\#*)
if (( ${#codecs[@]} )); then
    grep -H '^Codec:' "${codecs[@]}" || true
else
    echo 'No HDA codec data found. Check kernel audio support, firmware and ALSA UCM profiles.'
fi
target=/etc/modprobe.d/alsa-honor.conf
if (( ! ENABLE_QUIRK && ! REMOVE_LEGACY )); then
    echo 'Audio inspection complete; no configuration was installed.'
    [[ ! -f $target ]] || echo 'Existing alsa-honor.conf found. Review it; --remove-legacy-config removes recognized repository settings.'
    exit 0
fi
(( EUID == 0 )) || { echo 'Run configuration changes with sudo.' >&2; exit 1; }
if (( REMOVE_LEGACY )) && [[ ! -f $target ]]; then
    echo 'No alsa-honor.conf to remove.'; exit 0
fi
if command -v update-initramfs >/dev/null; then
    initramfs_tool=update-initramfs
elif command -v dracut >/dev/null; then
    initramfs_tool=dracut
elif command -v mkinitcpio >/dev/null; then
    initramfs_tool=mkinitcpio
else
    echo 'No supported initramfs updater found; refusing audio config changes.' >&2; exit 1
fi
rebuild_initramfs() {
    case "$initramfs_tool" in
        update-initramfs) update-initramfs -u -k all ;;
        dracut) dracut --regenerate-all --force ;;
        mkinitcpio) mkinitcpio -P ;;
    esac
}
if (( REMOVE_LEGACY )); then
    # Refuse to remove user-added options or unrelated configuration.
    if grep -Ev '^[[:space:]]*(#.*)?$|^options snd-hda-intel model=alc256-asus-mic$|^options snd-sof-intel-hda-common dmic_num=2$' "$target"; then
        echo 'Config contains custom settings; remove or edit it manually.' >&2; exit 1
    fi
    honor_audio_update_config "$target" '' rebuild_initramfs
    echo 'Legacy ALSA config removed and initramfs rebuilt; reboot to apply.'
    exit 0
fi
[[ $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) == HONOR && $(cat /sys/class/dmi/id/product_name 2>/dev/null) == XWC-P ]] || {
    echo 'Refusing audio model override on an unrecognized machine.' >&2; exit 1;
}
if (( ${#codecs[@]} == 0 )) || ! grep -q '^Codec: Realtek ALC256$' "${codecs[@]}"; then
    echo 'ALC256 was not detected; refusing the experimental model override.' >&2; exit 1
fi
install -d /etc/modprobe.d
honor_audio_update_config "$target" "$HERE/alsa-honor.conf" rebuild_initramfs
echo 'Experimental headset model installed and initramfs rebuilt; reboot to test.'
