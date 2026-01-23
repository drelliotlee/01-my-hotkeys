#!/bin/bash
sleep 0.2 # for some reason, initial sleep needed to reset click state
xdotool click --delay 60 --repeat 3 1
sleep 0.1
xdotool key ctrl+c
sleep 0.05

ACTIVE_WINDOW=$(xdotool getactivewindow)
WINDOW_NAME=$(xdotool getwindowname "$ACTIVE_WINDOW")

if [[ "$WINDOW_NAME" == *"Tinder"* ]]; then
  CLIPBOARD_CONTENT=$(xclip -selection clipboard -o)
  echo -n "I. ${CLIPBOARD_CONTENT}" | xclip -selection clipboard -i
fi