#!/bin/bash

# direction: up, down, or mute
ACTION="$1"
NOTIFY_ID_FILE="$HOME/.cache/volume_notify_id"
mkdir -p "$(dirname "$NOTIFY_ID_FILE")"

# Handle volume change
step="5%"

case "$ACTION" in
  up)
    pactl set-sink-volume @DEFAULT_SINK@ +$step
    ;;
  down)
    pactl set-sink-volume @DEFAULT_SINK@ -$step
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
  *)
    echo "Usage: $0 up|down|mute"
    exit 1
    ;;
esac


# Get current volume/mute status
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

# Build notification content
if [ "$muted" == "yes" ]; then
  text="🔇 Muted"
else
  text="🔊 Volume: $volume"
fi

# Replace previous notification
if [ -f "$NOTIFY_ID_FILE" ]; then
  notify_id=$(cat "$NOTIFY_ID_FILE")
else
  notify_id=0
fi

new_id=$(dunstify -a volume -r "$notify_id" "$text" -t 1000 -p)
echo "$new_id" > "$NOTIFY_ID_FILE"

