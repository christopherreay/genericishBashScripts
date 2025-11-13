#!/bin/bash

# Disable middle mouse button to prevent accidental paste

# Find the mouse device ID
MOUSE_ID=$(xinput list | grep "093A:3848 Mouse" | grep -o 'id=[0-9]*' | cut -d= -f2)

if [ -n "$MOUSE_ID" ]; then
    # Disable middle button (set button 2 to 0)
    xinput set-button-map $MOUSE_ID 1 0 3
    echo "Middle mouse button disabled for device ID: $MOUSE_ID"
else
    echo "Mouse device not found"
fi