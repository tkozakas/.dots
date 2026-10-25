#!/usr/bin/env bash
# Volume / mic controls using wpctl (PipeWire native).
# Bound from Hyprland keybinds + Keychron knob (XF86AudioRaiseVolume etc).

set -euo pipefail

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

SINK="@DEFAULT_AUDIO_SINK@"
SRC="@DEFAULT_AUDIO_SOURCE@"
STEP="0.05"      # 5%
MAX="1.5"        # 150% boost ceiling

# --- helpers ---------------------------------------------------------------

# Returns volume as integer percent (0-150). Mute reports 0.
get_volume_pct() {
    # `wpctl get-volume` -> "Volume: 0.60" or "Volume: 0.60 [MUTED]"
    local out vol
    out=$(wpctl get-volume "$SINK")
    if [[ "$out" == *"[MUTED]"* ]]; then
        echo 0
        return
    fi
    vol=$(awk '{print $2}' <<<"$out")
    awk -v v="$vol" 'BEGIN { printf "%d", v * 100 + 0.5 }'
}

get_mic_pct() {
    local out vol
    out=$(wpctl get-volume "$SRC")
    if [[ "$out" == *"[MUTED]"* ]]; then
        echo 0
        return
    fi
    vol=$(awk '{print $2}' <<<"$out")
    awk -v v="$vol" 'BEGIN { printf "%d", v * 100 + 0.5 }'
}

is_muted()     { [[ "$(wpctl get-volume "$SINK")" == *"[MUTED]"* ]]; }
is_mic_muted() { [[ "$(wpctl get-volume "$SRC")"  == *"[MUTED]"* ]]; }

get_volume() {
    local p; p=$(get_volume_pct)
    if is_muted || (( p == 0 )); then echo "Muted"; else echo "$p %"; fi
}

get_icon() {
    local current="$(get_volume)"
    if [[ "$current" == "Muted" ]]; then
        echo "$iDIR/volume-mute.png"
    elif [[ "${current%\%}" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "${current%\%}" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

get_mic_icon() {
    if is_mic_muted; then
        echo "$iDIR/microphone-mute.png"
    else
        echo "$iDIR/microphone.png"
    fi
}

notify_user() {
    local p; p=$(get_volume_pct)
    if is_muted; then
        notify-send -e -h string:x-canonical-private-synchronous:volume_notif \
            -u low -i "$(get_icon)" " Volume:" " Muted" 2>/dev/null || true
    else
        notify-send -e -h int:value:"$p" \
            -h string:x-canonical-private-synchronous:volume_notif \
            -u low -i "$(get_icon)" " Volume Level:" " ${p} %" 2>/dev/null || true
        [[ -x "$sDIR/Sounds.sh" ]] && "$sDIR/Sounds.sh" --volume
    fi
}

notify_mic_user() {
    local p icon
    p=$(get_mic_pct); icon=$(get_mic_icon)
    notify-send -e -h int:value:"$p" \
        -h string:x-canonical-private-synchronous:volume_notif \
        -u low -i "$icon" " Mic Level:" " ${p} %" 2>/dev/null || true
}

# --- actions ---------------------------------------------------------------

inc_volume() {
    if is_muted; then
        wpctl set-mute "$SINK" 0
    else
        wpctl set-volume -l "$MAX" "$SINK" "${STEP}+"
    fi
    notify_user
}

dec_volume() {
    if is_muted; then
        wpctl set-mute "$SINK" 0
    else
        wpctl set-volume "$SINK" "${STEP}-"
    fi
    notify_user
}

toggle_mute() {
    wpctl set-mute "$SINK" toggle
    if is_muted; then
        notify-send -e -u low -i "$iDIR/volume-mute.png" " Mute" 2>/dev/null || true
    else
        notify-send -e -u low -i "$(get_icon)" " Volume:" " Switched ON" 2>/dev/null || true
    fi
}

toggle_mic() {
    wpctl set-mute "$SRC" toggle
    if is_mic_muted; then
        notify-send -e -u low -i "$iDIR/microphone-mute.png" \
            " Microphone:" " Switched OFF" 2>/dev/null || true
    else
        notify-send -e -u low -i "$iDIR/microphone.png" \
            " Microphone:" " Switched ON" 2>/dev/null || true
    fi
}

toggle_mic() {
    wpctl set-mute "$SRC" toggle
    if is_mic_muted; then
        notify-send -e -u low -i "$iDIR/microphone-mute.png" \
            " Microphone:" " Switched OFF"
    else
        notify-send -e -u low -i "$iDIR/microphone.png" \
            " Microphone:" " Switched ON"
    fi
}

inc_mic_volume() {
    if is_mic_muted; then wpctl set-mute "$SRC" 0; fi
    wpctl set-volume "$SRC" "${STEP}+"
    notify_mic_user
}

dec_mic_volume() {
    if is_mic_muted; then wpctl set-mute "$SRC" 0; fi
    wpctl set-volume "$SRC" "${STEP}-"
    notify_mic_user
}

# --- dispatch --------------------------------------------------------------

case "${1:---get}" in
    --get)           get_volume ;;
    --inc)           inc_volume ;;
    --dec)           dec_volume ;;
    --toggle)        toggle_mute ;;
    --toggle-mic)    toggle_mic ;;
    --get-icon)      get_icon ;;
    --get-mic-icon)  get_mic_icon ;;
    --mic-inc)       inc_mic_volume ;;
    --mic-dec)       dec_mic_volume ;;
    *)               get_volume ;;
esac
