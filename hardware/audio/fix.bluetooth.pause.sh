#!/bin/bash

# Fix for FreeBuds 6i Bluetooth audio causing MPV to pause/hang
# Restarts PipeWire services to clear stuck audio routing

echo "Restarting PipeWire services to fix Bluetooth audio sync..."

systemctl --user restart pipewire pipewire-pulse wireplumber

sleep 2

echo "PipeWire services restarted. Audio should now work without reboot."
echo "If MPV is still paused, manually resume playback."