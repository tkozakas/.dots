#!/usr/bin/env bash
# Pick an audio output sink via rofi, set it as default, and move
# existing streams over. Bound to SUPER+F2 and waybar middle-click.

set -euo pipefail

DEFAULT=$(pactl get-default-sink)

# Try JSON first (clean parsing), fall back to text parsing.
mapfile -t SINKS < <(
  pactl -f json list sinks 2>/dev/null \
    | jq -r '.[] | "\(.name)\t\(.description)"' 2>/dev/null \
  || pactl list sinks | awk '
      /^\tName: /        { name=$2 }
      /^\tDescription: / { sub(/^\tDescription: /, ""); print name "\t" $0 }
    '
)

if [[ ${#SINKS[@]} -eq 0 ]]; then
  notify-send -u critical "Audio" "No sinks found" 2>/dev/null
  exit 1
fi

menu=""
for line in "${SINKS[@]}"; do
  name="${line%%	*}"
  desc="${line#*	}"
  marker="   "
  [[ "$name" == "$DEFAULT" ]] && marker=" ● "
  menu+="${marker}${desc}"$'\n'
done

picked=$(printf '%s' "$menu" \
  | rofi -dmenu -i -no-custom -p "Audio output" \
      -config "$HOME/.config/hypr/rofi/config.rasi")
[[ -z "$picked" ]] && exit 0
picked_desc="${picked:3}"

target=""
for line in "${SINKS[@]}"; do
  name="${line%%	*}"
  desc="${line#*	}"
  if [[ "$desc" == "$picked_desc" ]]; then
    target="$name"
    break
  fi
done
[[ -z "$target" ]] && exit 1

pactl set-default-sink "$target"
while read -r idx _; do
  pactl move-sink-input "$idx" "$target" 2>/dev/null || true
done < <(pactl list short sink-inputs)

notify-send -e \
  -h string:x-canonical-private-synchronous:audio-sink \
  -i audio-speakers \
  "Audio output" "$picked_desc" 2>/dev/null || true
