#!/bin/bash
echo "Launching Chrome window #1 (Tinder)..."
/usr/bin/google-chrome-stable --new-window "https://tinder.com/app/recs" &
sleep 0.5

echo "Moving window #1 to target monitor (Super+Shift+Up)..."
xdotool key Super+Shift+Up
sleep 0.2

echo "Tiling window #1 LEFT (Super+Left)..."
xdotool key Super+Left
sleep 0.2

echo "Launching Chrome window #2 (Gemini)..."
/usr/bin/google-chrome-stable --new-window "https://gemini.google.com/app" &
sleep 0.5

echo "Moving window #2 to target monitor (Super+Shift+Up)..."
xdotool key Super+Shift+Up
sleep 0.2

echo "Tiling window #2 RIGHT (Super+Right)..."
xdotool key Super+Right
sleep 0.2

WID=$(wmctrl -l | grep -i "Gemini" | tail -1 | awk '{print $1}')
sleep 0.5
wmctrl -i -r "$WID" -T "Indo-Gemini"