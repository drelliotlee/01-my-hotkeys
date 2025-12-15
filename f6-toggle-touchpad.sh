#!/bin/bash

# A more robust script to toggle the "VEN_04F3:00 04F3:311C Touchpad" device.
# It uses 'xinput set-prop' directly to avoid potential conflicts with
# desktop environment settings.

DEVICE_NAME="VEN_04F3:00 04F3:311C Touchpad"

# Find the device ID by searching for its name. Using the name is
# more reliable than the ID in scripts, as the ID can change.
DEVICE_ID=$(xinput list --id-only "$DEVICE_NAME")

# Check if a device ID was found.
if [ -z "$DEVICE_ID" ]; then
    echo "Error: Device '$DEVICE_NAME' not found. Is it connected?"
    exit 1
fi

# Get the current enabled state of the device using its property name.
# We use awk to extract the numerical value at the end of the line.
CURRENT_STATE=$(xinput list-props "$DEVICE_ID" | awk '/Device Enabled/ {print $NF}')

# Check the state and toggle it.
if [ "$CURRENT_STATE" == "1" ]; then
    xinput set-prop "$DEVICE_ID" "Device Enabled" 0
    echo "Disabled '$DEVICE_NAME'."
elif [ "$CURRENT_STATE" == "0" ]; then
    xinput set-prop "$DEVICE_ID" "Device Enabled" 1
    echo "Enabled '$DEVICE_NAME'."
else
    echo "Error: Could not determine the current state of '$DEVICE_NAME'."
    exit 1
fi

# Verify the new state and provide feedback.
NEW_STATE=$(xinput list-props "$DEVICE_ID" | awk '/Device Enabled/ {print $NF}')
if [ "$NEW_STATE" != "$CURRENT_STATE" ]; then
    echo "Toggle successful. New state: $([ "$NEW_STATE" == "1" ] && echo "Enabled" || echo "Disabled")."
else
    echo "Toggle failed. The device state did not change."
fi
