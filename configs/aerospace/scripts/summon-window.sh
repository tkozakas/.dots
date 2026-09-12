#!/bin/bash
# Bring the focused window to the previously focused workspace instead of
# staying on the workspace the window dragged us to.

win=$(aerospace list-windows --focused --format '%{window-id}')
[ -z "$win" ] && exit 0
aerospace workspace-back-and-forth
ws=$(aerospace list-workspaces --focused)
aerospace move-node-to-workspace --window-id "$win" --focus-follows-window "$ws"
