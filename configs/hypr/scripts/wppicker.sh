#!/bin/bash

# No trailing slash here
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

cd "$WALLPAPER_DIR" || exit 1

SELECTED_WALL=$(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.jpeg" \) -printf "%f\n" | sort | \
                rofi -config "$HOME/.config/hypr/rofi/wallpaper.rasi" -dmenu -p "Select Wallpaper")

[ -z "$SELECTED_WALL" ] && exit 1

SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

[ ! -f "$SELECTED_PATH" ] && exit 1

mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"

matugen --config ~/.config/hypr/matugen/config.toml image "$SYMLINK_PATH"
swww img "$SYMLINK_PATH" --transition-type none 

echo "Wallpaper changed."
