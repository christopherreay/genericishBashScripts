#!/bin/bash

# direction: up, down, or mute
ACTION="$1"
NOTIFY_ID_FILE="$HOME/.cache/volume_notify_id"
mkdir -p "$(dirname "$NOTIFY_ID_FILE")"

# Handle volume change
step="0.05"  # 5% as decimal for wpctl

case "$ACTION" in
  up)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ ${step}+
    ;;
  down)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ ${step}-
    ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  *)
    echo "Usage: $0 up|down|mute"
    exit 1
    ;;
esac


# Get current volume/mute status
volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
volume=$(echo "$volume_info" | awk '{printf "%.0f%%", $2 * 100}')
muted=$(echo "$volume_info" | grep -q "MUTED" && echo "yes" || echo "no")

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

