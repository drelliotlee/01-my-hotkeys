#!/bin/bash
# Launch Chrome: Moves window to the top monitor (using Super+Shift+Up) and then tiles it.

# --- 1. Get Current Desktop/Workspace ID ---
CURRENT_DESKTOP=$(wmctrl -d | awk '/\*/ {print $1; exit}')

# --- 2. Check for ANY Chrome window on the CURRENT Desktop ---
CHROME_PRESENT=$(wmctrl -l | awk -v current_desk=$CURRENT_DESKTOP '
  $2 == current_desk && /Google Chrome/ { print "yes"; exit }
')

# --- 3. Launch, Move to Monitor, and Tile ---

# Launch Chrome anywhere—Cinnamon will place it on the active monitor.
echo "Launching Chrome window..."
/usr/bin/google-chrome-stable --new-window &
sleep 0.5 # Give the window manager time to draw the window

# Find the newly launched Chrome window (the one that's currently active/focused)
# This is crucial so xdotool targets the correct window.
NEW_WINDOW_ID=$(xdotool getactivewindow)
echo "New window ID: ${NEW_WINDOW_ID}"
sleep 0.2

# Move the window to the target monitor (the 'top 2nd monitor' which is virtually 'up/down').
echo "Moving window to target monitor (Super+Shift+Up)..."
xdotool key Super+Shift+Up
sleep 0.2

# Now that the window is on the correct monitor, perform the final tiling.
if [ "$CHROME_PRESENT" != "yes" ]; then
  echo "⬅️ No Chrome window found. Tiling LEFT (Super+Left)."
  xdotool key Super+Left
else
  echo "➡️ Chrome window found. Tiling RIGHT (Super+Right)."
  xdotool key Super+Right
fi