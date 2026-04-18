#!/bin/bash

DOTS_DIR="$HOME/.dots"
CONFIGS_DIR="$DOTS_DIR/configs/hyprland"
HYPR_TARGET="$HOME/.config/hypr"

# Get current config name from symlink
CURRENT=""
if [ -L "$HYPR_TARGET" ]; then
    CURRENT=$(basename "$(readlink "$HYPR_TARGET")")
fi

# List available configs
CONFIGS=$(find "$CONFIGS_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)

# Mark current in the list
DISPLAY_LIST=""
while IFS= read -r name; do
    if [ "$name" = "$CURRENT" ]; then
        DISPLAY_LIST+="  $name (current)\n"
    else
        DISPLAY_LIST+="  $name\n"
    fi
done <<< "$CONFIGS"

# Show rofi picker
SELECTED=$(echo -e "$DISPLAY_LIST" | rofi -config "$HOME/.config/hypr/rofi/wallpaper.rasi" -dmenu -p "Select Config")

[ -z "$SELECTED" ] && exit 1

# Strip icon and (current) marker
SELECTED=$(echo "$SELECTED" | sed 's/^  //;s/ (current)$//')

SELECTED_PATH="$CONFIGS_DIR/$SELECTED"
[ ! -d "$SELECTED_PATH" ] && exit 1

# Skip if already active
[ "$SELECTED" = "$CURRENT" ] && exit 0

# Swap symlink
ln -sfn "$SELECTED_PATH" "$HYPR_TARGET"

# Reload hyprland
hyprctl reload

notify-send "Hyprland Config" "Switched to: $SELECTED" -i preferences-system
