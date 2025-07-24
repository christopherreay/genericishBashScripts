#!/bin/bash
current=$(brightnessctl get)
max=$(brightnessctl max)
percent=$(( 100 * current / max ))

if [ "$percent" -lt 10 ]; then
  brightnessctl set +1%
elif [ "$percent" -lt 30 ]; then
  brightnessctl set +3%
elif [ "$percent" -lt 50 ]; then
  brightnessctl set +5%
else
  brightnessctl set +10%
fi

