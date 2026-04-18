#!/bin/bash

THEMES_DIR="$HOME/.dots/configs/themes"
THEMES_JSON="$THEMES_DIR/themes.json"
STATE_FILE="$HOME/.config/current-theme"

# Read theme names from themes.json
THEME_NAMES=$(jq -r '.themes[].name' "$THEMES_JSON")

# Get current theme for display
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "none")

# Show rofi picker
SELECTED=$(echo "$THEME_NAMES" | rofi -config "$HOME/.config/hypr/rofi/wallpaper.rasi" -dmenu -p "Theme [$CURRENT]")

[ -z "$SELECTED" ] && exit 0

# Look up directory name from themes.json
THEME_DIR=$(jq -r --arg name "$SELECTED" '.themes[] | select(.name == $name) | .dir' "$THEMES_JSON")

[ -z "$THEME_DIR" ] || [ ! -d "$THEMES_DIR/$THEME_DIR" ] && {
    notify-send "Theme Picker" "Theme '$SELECTED' not found"
    exit 1
}

SRC="$THEMES_DIR/$THEME_DIR"

# 1. Alacritty — copy theme file (hot-reloads automatically)
cp "$SRC/alacritty.toml" "$HOME/.config/alacritty/theme.toml"

# 2. tmux — copy theme file and reload all servers
cp "$SRC/tmux.conf" "$HOME/.tmux/theme.conf"
for server in $(tmux list-servers -F '#{socket_path}' 2>/dev/null); do
    tmux -S "$server" source-file "$HOME/.tmux.conf" 2>/dev/null
done
tmux source-file "$HOME/.tmux.conf" 2>/dev/null

# 3. nvim — write theme name and signal all running instances
cp "$SRC/nvim_colorscheme" "$HOME/.config/nvim/theme"
pkill -USR1 nvim 2>/dev/null

# 4. opencode — set to "system" theme (adapts to terminal colors)
TUI_JSON="$HOME/.config/opencode/tui.json"
if [ -f "$TUI_JSON" ]; then
    jq '.theme = "system"' "$TUI_JSON" > "$TUI_JSON.tmp" && mv "$TUI_JSON.tmp" "$TUI_JSON"
fi

# Save current theme
echo "$SELECTED" > "$STATE_FILE"

notify-send "Theme Picker" "Switched to $SELECTED" -t 2000
