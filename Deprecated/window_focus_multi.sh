#!/bin/bash
# window_focus_multi.sh - Multi-tap window focus switcher
# Usage: Map Ctrl+M to this script
# Tap Space 1-4 times (while holding Ctrl) to focus different quadrants

# as of jan 22 2026 this is also deprecated in favor of 06/touchpad-as-Fkeys project

STATE_FILE="/tmp/window_focus_state"
PID_FILE="/tmp/window_focus_timer.pid"
LOG_FILE="/tmp/window_focus_multi.log"
TIMEOUT=0.5
SCRIPT_DIR="/home/elliot/Repos/01-my-hotkeys/Deprecated"
WINDOW_FOCUS="$SCRIPT_DIR/window_focus.sh"

# Debug logging
exec >> "$LOG_FILE" 2>&1
echo "=== $(date '+%Y-%m-%d %H:%M:%S.%3N') - Script triggered ==="

# Kill existing timer if running
if [[ -f "$PID_FILE" ]]; then
    old_pid=$(cat "$PID_FILE")
    echo "Killing previous timer: $old_pid"
    kill "$old_pid" 2>/dev/null
    rm -f "$PID_FILE"
fi

# Read or initialize state
if [[ -f "$STATE_FILE" ]]; then
    read -r count last_time < "$STATE_FILE"
    echo "Read state: count=$count, last_time=$last_time"
else
    count=0
    last_time=0
    echo "No previous state, initializing"
fi

current_time=$(date +%s.%N)
time_diff=$(echo "$current_time - $last_time" | bc)
echo "Current time: $current_time, Time diff: $time_diff"

# Check if within timeout window
if (( $(echo "$time_diff < $TIMEOUT" | bc -l) )); then
    count=$((count + 1))
    [[ $count -gt 4 ]] && count=4
    echo "Within timeout - incrementing to: $count"
else
    count=1
    echo "Timeout exceeded - resetting to: 1"
fi

# Save new state
echo "$count $current_time" > "$STATE_FILE"
echo "Saved state: count=$count"

# Execute window_focus IMMEDIATELY for instant visual feedback
echo "Executing immediately: $WINDOW_FOCUS $count"
"$WINDOW_FOCUS" "$count" >> "$LOG_FILE" 2>&1

# Start timer in background just to reset the state after timeout
echo "Starting reset timer for $TIMEOUT seconds..."
(
    sleep "$TIMEOUT"
    echo "=== $(date '+%Y-%m-%d %H:%M:%S.%3N') - Timer fired (cleanup) ===" >> "$LOG_FILE"
    rm -f "$STATE_FILE" "$PID_FILE"
) &

# Save timer PID
timer_pid=$!
echo "$timer_pid" > "$PID_FILE"
echo "Timer PID: $timer_pid"
echo "===================================================="
