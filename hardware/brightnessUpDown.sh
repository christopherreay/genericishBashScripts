#!/bin/bash

# Require direction
if [ "$1" != "up" ] && [ "$1" != "down" ]; then
  echo "Usage: $0 <up|down>"
  exit 1
fi

# File to store notify ID
NOTIFY_ID_FILE="$HOME/.cache/brightness_notify_id"
mkdir -p "$(dirname "$NOTIFY_ID_FILE")"

# Get brightness
current=$(brightnessctl get)
max=$(brightnessctl max)
percent=$(( 100 * current / max ))

# Step size logic
if [ "$percent" -lt 10 ]; then
  step=1
elif [ "$percent" -lt 30 ]; then
  step=3
elif [ "$percent" -lt 50 ]; then
  step=5
else
  step=10
fi

# Calculate change
if [ "$1" == "up" ]; then
  change="+${step}%"
else
  target=$(( percent - step ))
  [ "$target" -lt 1 ] && exit 0  # if already at 1%, do nothing
  change="${step}%-"
fi

brightnessctl set "$change"

# New brightness after change
new_percent=$(( 100 * $(brightnessctl get) / $(brightnessctl max) ))

# Pick icon based on brightness
if [ "$new_percent" -le 10 ]; then
  icon="🔅"
elif [ "$new_percent" -le 40 ]; then
  icon="🔆"
elif [ "$new_percent" -le 70 ]; then
  icon="🌤️"
else
  icon="☀️"
fi


# Read existing ID if available
if [ -f "$NOTIFY_ID_FILE" ]; then
  notify_id=$(cat "$NOTIFY_ID_FILE")
else
  notify_id=0
fi

# Send notification and capture ID
new_id=$(dunstify -a brightnessctl -r "$notify_id" "Brightness: $icon ${new_percent}%" -t 1000 -p)
#new_id=$(notify-send --hint=int:id:"$notify_id" "Brightness: ${new_percent}%" --print-id)
echo "$new_id" > "$NOTIFY_ID_FILE"
