#!/bin/bash
# Rofi theme picker — Hyprland keybind wrapper for theme-switch

THEMES_DIR="$HOME/.dots/configs/themes"
THEMES_JSON="$THEMES_DIR/themes.json"
STATE_FILE="$HOME/.config/current-theme"

THEME_NAMES=$(jq -r '.themes[].name' "$THEMES_JSON")
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "none")

SELECTED=$(echo "$THEME_NAMES" | rofi -config "$HOME/.config/hypr/rofi/wallpaper.rasi" -dmenu -p "Theme [$CURRENT]")

[ -z "$SELECTED" ] && exit 0

"$HOME/.config/themes/theme-switch.sh" "$SELECTED"

notify-send "Theme Picker" "Switched to $SELECTED" -t 2000
