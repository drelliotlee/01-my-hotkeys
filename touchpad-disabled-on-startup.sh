#!/bin/bash

# this is a script to add ot linux mints startup so touchpad is disabled on boot
DEVICE_NAME="VEN_04F3:00 04F3:311C Touchpad"
DEVICE_ID=$(xinput list --id-only "$DEVICE_NAME")
if [ -n "$DEVICE_ID" ]; then
  xinput set-prop "$DEVICE_ID" "Device Enabled" 0
fi