#!/bin/bash
current=$(brightnessctl get)
max=$(brightnessctl max)
percent=$(( 100 * current / max ))

echo $current $max $percent

if [ "$percent" -le 10 ]; then
  brightnessctl set 1%-
elif [ "$percent" -le 30 ]; then
  brightnessctl set 3%-  
elif [ "$percent" -le 50 ]; then
  brightnessctl set 5%-
else
  brightnessctl set 10%-
fi

