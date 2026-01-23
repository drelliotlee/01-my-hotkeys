#!/bin/bash
# this is deprecated because i realized its smarter to just prepend the "I. " during copy time
xdotool keyup Alt_L Alt_R v V
sleep 0.05
xdotool key --clearmodifiers ctrl+v
sleep 0.05

ACTIVE_WINDOW=$(xdotool getactivewindow)
WINDOW_NAME=$(xdotool getwindowname "$ACTIVE_WINDOW")

if [[ "$WINDOW_NAME" == *"Indo-Gemini"* ]]; then
  xdotool key --clearmodifiers Page_Up
  sleep 0.05
  xdotool type "I. "
  sleep 0.05
  xdotool key --clearmodifiers Page_Down
fi