#!/bin/bash
# Меняй темы здесь:
DARK="$HOME/.config/kitty/theme-dark.conf"
LIGHT="$HOME/.config/kitty/theme-light.conf"

STATE="/tmp/kitty-theme-state"

if [ -f "$STATE" ] && [ "$(cat "$STATE")" = "dark" ]; then
    kitty @ set-colors --all --configured "$LIGHT"
    echo "light" > "$STATE"
else
    kitty @ set-colors --all --configured "$DARK"
    echo "dark" > "$STATE"
fi
