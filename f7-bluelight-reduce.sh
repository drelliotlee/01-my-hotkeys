#!/bin/bash

# Simple xsct toggle script
# Toggles between normal (6500K) and very red (2000K)

STATE_FILE="$HOME/.xsct_toggle_state"

get_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "normal"
    fi
}

set_state() {
    echo "$1" > "$STATE_FILE"
}

# Check if xsct is available
if ! command -v xsct &> /dev/null; then
    echo "Error: xsct not found. Please install it first:"
    echo "Ubuntu/Debian: sudo apt install xsct"
    echo "Arch: sudo pacman -S sct"
    echo "Fedora: sudo dnf install sct"
    exit 1
fi

current=$(get_state)

case "$current" in
    "normal")
        xsct 2000
        set_state "red"
        echo "🔴 VERY RED (2000K)"
        ;;
    *)
        xsct 6500
        set_state "normal"
        echo "⚪ NORMAL (6500K)"
        ;;
esac
