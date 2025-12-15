#!/bin/bash
# /usr/local/bin/study
# chmod +x /usr/local/bin/study
#
# The panel toolbar can run 'study' every second to output the time.
# Map F4 to 'study toggle' to start/stop the timer.

STATE_FILE="/home/elliot/.study_timer_state"
DISPLAY_STATE_FILE="/home/elliot/.study_timer_display"
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/complete.oga"

# Ensure consistent day math in your locale/timezone
: "${TZ:=Asia/Bangkok}"
export TZ

# Initialize state files if they don't exist
if [[ ! -f "$STATE_FILE" ]]; then
    echo "0" > "$STATE_FILE"
fi
if [[ ! -f "$DISPLAY_STATE_FILE" ]]; then
    echo "on" > "$DISPLAY_STATE_FILE"
fi

# Function to play a sound file
play_sound() {
    # Try these players in order
    for cmd in paplay aplay play; do
        if command -v "$cmd" >/dev/null 2>&1; then
            "$cmd" "$SOUND_FILE" >/dev/null 2>&1 && return
        fi
    done
    # Fallback
    if [[ -f "/usr/share/sounds/alsa/Front_Left.wav" ]] && command -v aplay >/dev/null 2>&1; then
        aplay "/usr/share/sounds/alsa/Front_Left.wav" >/dev/null 2>&1
    fi
}

# Format seconds into H:MM:SS or M:SS
format_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(( (total_seconds % 3600) / 60 ))
    local seconds=$((total_seconds % 60))
    if (( hours > 0 )); then
        printf "%d:%02d:%02d" "$hours" "$minutes" "$seconds"
    else
        printf "%d:%02d" "$minutes" "$seconds"
    fi
}

# Current seconds, accounting for running timer
get_current_seconds() {
    local line accumulated_seconds start_time current_time elapsed
    line=$(cat "$STATE_FILE")
    accumulated_seconds=$(echo "$line" | awk '{print $1}')
    start_time=$(echo "$line" | awk '{print $2}')
    current_time=$(date +%s)
    if [[ -n "$start_time" ]]; then
        elapsed=$((current_time - start_time))
        echo $((accumulated_seconds + elapsed))
    else
        echo "$accumulated_seconds"
    fi
}

# --- COMMANDS ---
case "$1" in
    "days")
        # Today vs fixed start date
        start_date="2025-10-01"
        # Seconds since epoch for each (midnight local)
        start_s=$(date -d "$start_date 00:00:00" +%s)
        today_str=$(date +"%Y-%m-%d 00:00:00")
        today_s=$(date -d "$today_str" +%s)

        # Integer day difference
        diff_days=$(( (today_s - start_s) / 86400 ))
        # Don't go negative
        if (( diff_days < 0 )); then diff_days=0; fi

        # Human-friendly "October 2"
        pretty_today=$(date +"%B %-d")
        echo "${pretty_today} is day ${diff_days}"
        ;;

    "sync")
        target_dir="/home/elliot/Dropbox/Obsidian/STUDY"
        if [[ ! -d "$target_dir" ]]; then
            echo "Error: $target_dir not found."
            exit 1
        fi
        # Use a subshell to avoid leaking cwd
        (
            cd "$target_dir" || exit 1
            # Ensure repo exists
            if ! git rev-parse --is-inside-work-tree &>/dev/null; then
                echo "Error: $target_dir is not a Git repository."
                exit 1
            fi
            git add .
            # Commit only if there are changes
            if ! git diff --cached --quiet; then
                msg="$(date +"%Y-%m-%d %H:%M:%S %Z")"
                git commit -m "$msg"
            else
                echo "No staged changes to commit."
            fi
            git push
        )
        ;;

    "toggle")
        line=$(cat "$STATE_FILE")
        accumulated_seconds=$(echo "$line" | awk '{print $1}')
        start_time=$(echo "$line" | awk '{print $2}')

        if [[ -n "$start_time" ]]; then
            current_time=$(date +%s)
            elapsed=$((current_time - start_time))
            new_accumulated_seconds=$((accumulated_seconds + elapsed))
            echo "$new_accumulated_seconds" > "$STATE_FILE"
            echo "Timer stopped. Total: $(format_time "$new_accumulated_seconds")"
        else
            start_time=$(date +%s)
            echo "$accumulated_seconds $start_time" > "$STATE_FILE"
            echo "Timer started from $(format_time "$accumulated_seconds")"
        fi
        play_sound
        ;;

    "reset")
        echo "0" > "$STATE_FILE"
        echo "Timer reset to 0:00"
        ;;

    "set")
        if [[ -z "$2" ]]; then
            echo "Usage: study set H:MM"
            exit 1
        fi
        if [[ ! "$2" =~ ^[0-9]{1,2}:[0-9]{2}$ ]]; then
            echo "Error: Invalid time format. Use H:MM."
            exit 1
        fi
        IFS=':' read -r hours minutes <<< "$2"
        if (( hours > 23 )) || (( minutes > 59 )); then
            echo "Error: Invalid time. Hours must be 0-23, minutes 0-59."
            exit 1
        fi
        total_seconds=$(( (10#$hours * 3600) + (10#$minutes * 60) ))
        echo "$total_seconds" > "$STATE_FILE"
        echo "Timer set to $2"
        ;;

    "on")
        echo "on" > "$DISPLAY_STATE_FILE"
        echo "Study timer display turned on."
        ;;

    "off")
        echo "off" > "$DISPLAY_STATE_FILE"
        echo "Study timer display turned off."
        ;;

    # Optional: keep old 'day' as a gentle hint/alias
    "day")
        echo "Tip: Use 'study days' (no argument)."
        ;;

    *)
        display_status=$(cat "$DISPLAY_STATE_FILE")
        if [[ "$display_status" == "on" ]]; then
            total_seconds=$(get_current_seconds)
            formatted_time=$(format_time "$total_seconds")
            echo "Study Time: $formatted_time"
        else
            echo " "
        fi
        ;;
esac