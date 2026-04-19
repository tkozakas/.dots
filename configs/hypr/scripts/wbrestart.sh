#!/bin/zsh

killall -9 waybar
matugen -c ~/.config/hypr/matugen/config.toml image ~/.config/hypr/current_wallpaper
hyprctl reload
waybar &

