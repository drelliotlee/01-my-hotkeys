#!/bin/bash
# window_focus.sh - Focus window overlapping with center of each half of each display
# Usage: ./window_focus.sh 1|2|3|4
# Modes:
#   1 - Primary (eDP-1-1) left half
#   2 - Primary (eDP-1-1) right half
#   3 - Secondary (DP-1-3) left half
#   4 - Secondary (DP-1-3) right half

debug_print() { echo "[DEBUG] $1" >&2; }

get_display_info() {
    local display_name="$1"
    local line geometry width height x_offset y_offset
    line=$(xrandr --current | grep "^$display_name connected")
    [[ -z "$line" ]] && { debug_print "Display $display_name not found"; return 1; }
    geometry=$(echo "$line" | grep -o '[0-9]\{1,\}x[0-9]\{1,\}+[0-9]\{1,\}+[0-9]\{1,\}')
    [[ -z "$geometry" ]] && { debug_print "No geometry for $display_name"; return 1; }

    width="${geometry%%x*}"
    local rest="${geometry#*x}"
    height="${rest%%+*}"
    rest="${rest#*+}"
    x_offset="${rest%%+*}"
    y_offset="${rest#*+}"

    debug_print "$display_name: $width x $height @ +$x_offset+$y_offset"
    echo "$width $height $x_offset $y_offset"
}

calculate_coordinate() {
    local width="$1" height="$2" x_offset="$3" y_offset="$4" mode="$5"
    local target_x target_y

    # X position depends on left/right half
    case "$mode" in
        1|3) target_x=$((x_offset + width / 4));;      # left center
        2|4) target_x=$((x_offset + (width * 3) / 4));; # right center
    esac

    # Y position = center vertically
    target_y=$((y_offset + height / 2))
    echo "$target_x $target_y"
}

find_window_at_coordinate() {
    local x="$1" y="$2"
    local current_ws=$(xdotool get_desktop)
    local windows=$(xdotool search --desktop "$current_ws" --onlyvisible ".*" 2>/dev/null)
    [[ -z "$windows" ]] && return 1

    local topmost="" highest=0
    while read -r win; do
        [[ -z "$win" ]] && continue
        local info=$(xwininfo -id "$win" 2>/dev/null) || continue
        local wx wy ww wh
        wx=$(awk '/Absolute upper-left X:/ {print $4}' <<<"$info")
        wy=$(awk '/Absolute upper-left Y:/ {print $4}' <<<"$info")
        ww=$(awk '/Width:/ {print $2}' <<<"$info")
        wh=$(awk '/Height:/ {print $2}' <<<"$info")

        if (( x >= wx && x <= wx + ww && y >= wy && y <= wy + wh )); then
            (( win > highest )) && { highest=$win; topmost=$win; }
        fi
    done <<<"$windows"

    [[ -n "$topmost" ]] && echo "$topmost"
}

activate_window() {
    local win="$1"
    local name=$(xdotool getwindowname "$win" 2>/dev/null) || return 1
    debug_print "Activating: $name ($win)"
    xdotool set_desktop_for_window "$win" "$(xdotool get_desktop)" 2>/dev/null
    xdotool windowactivate "$win" 2>/dev/null
    
    # If window name contains "Gemini", click at relative position
    if [[ "$name" == *"Gemini"* ]]; then
        sleep 0.1
        local info=$(xwininfo -id "$win" 2>/dev/null) || return 0
        local wx wy
        wx=$(awk '/Absolute upper-left X:/ {print $4}' <<<"$info")
        wy=$(awk '/Absolute upper-left Y:/ {print $4}' <<<"$info")
        
        # Calculate relative offset: from (2194, 7) to (3288, 2245)
        # Offset: x+1094, y+2238
        local click_x=$((wx + 1094))
        local click_y=$((wy + 2238))
        
        debug_print "Clicking Gemini window at ($click_x, $click_y)"
        xdotool mousemove "$click_x" "$click_y"
        xdotool click 1
    # If window name contains "Tinder", click at relative position
    elif [[ "$name" == *"Tinder"* ]]; then
        sleep 0.1
        local info=$(xwininfo -id "$win" 2>/dev/null) || return 0
        local wx wy
        wx=$(awk '/Absolute upper-left X:/ {print $4}' <<<"$info")
        wy=$(awk '/Absolute upper-left Y:/ {print $4}' <<<"$info")
        
        # Calculate relative offset: from (0, 0) to (936, 2399)
        # Offset: x+936, y+2399
        local click_x=$((wx + 936))
        local click_y=$((wy + 2399))
        
        debug_print "Clicking Tinder window at ($click_x, $click_y)"
        xdotool mousemove "$click_x" "$click_y"
        xdotool click 1
    fi
}

main() {
    local mode="$1"
    [[ "$mode" =~ ^[1-4]$ ]] || { echo "Usage: $0 1|2|3|4"; exit 1; }

    local display_info width height x_offset y_offset
    case "$mode" in
        1|2) display_info=$(get_display_info "eDP-1-1") || exit 1;; # primary
        3|4) display_info=$(get_display_info "DP-1-3") || exit 1;;   # secondary
    esac
    read -r width height x_offset y_offset <<<"$display_info"
    read -r target_x target_y <<<"$(calculate_coordinate "$width" "$height" "$x_offset" "$y_offset" "$mode")"

    local win=$(find_window_at_coordinate "$target_x" "$target_y") || { debug_print "No window"; exit 1; } 
    activate_window "$win"

    # Kill any existing highlight-pointer processes from previous taps
    pkill -f "highlight-pointer" 2>/dev/null
    
    local HIGHLIGHT_YELLOW=("/home/elliot/Repos/01-my-hotkeys/highlight-pointer/highlight-pointer" "-c" "#FFFF00" "-r" "45")
    local HIGHLIGHT_BLACK=("/home/elliot/Repos/01-my-hotkeys/highlight-pointer/highlight-pointer" "-c" "#000000" "-r" "30")
    xdotool mousemove "$target_x" "$target_y"
    
    # Show large yellow circle in background
    "${HIGHLIGHT_YELLOW[@]}" &
    local pid_yellow=$!
    
    # Small delay to ensure yellow renders first
    sleep 0.05
    
    # Show smaller black circle on top
    "${HIGHLIGHT_BLACK[@]}" &
    local pid_black=$!
    
    sleep 0.5
    kill "$pid_yellow" "$pid_black" 2>/dev/null
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi