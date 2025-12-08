#!/bin/zsh

killall -9 waybar
matugen -c ~/.dotfiles/hypr/matugen/config.toml image ~/.dotfiles/hypr/current_wallpaper
hyprctl reload
waybar &

