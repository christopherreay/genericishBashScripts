#!/bin/bash
# Normal Power Mode - Balanced performance and power

echo "Enabling normal power mode..."

# CPU: Set to powersave governor (still efficient but responsive)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave | sudo tee "$cpu" > /dev/null
done

# GPU: Enable runtime power management
echo auto | sudo tee /sys/bus/pci/devices/0000:01:00.0/power/control > /dev/null

# All PCI devices: Enable runtime PM
for dev in /sys/bus/pci/devices/*/power/control; do
    echo auto | sudo tee "$dev" > /dev/null 2>&1
done

# USB: Enable autosuspend
for dev in /sys/bus/usb/devices/*/power/control; do
    echo auto | sudo tee "$dev" > /dev/null 2>&1
done

# Wireless: Enable power saving
sudo iw dev wlp62s0 set power_save on 2>/dev/null

# SATA: Balanced link power management
for policy in /sys/class/scsi_host/host*/link_power_management_policy; do
    echo med_power_with_dipm | sudo tee "$policy" > /dev/null 2>&1
done

# Audio: Enable power saving
echo 1 | sudo tee /sys/module/snd_hda_intel/parameters/power_save > /dev/null 2>&1

echo "Normal power mode enabled. Current power draw:"
cat /sys/class/power_supply/BAT*/power_now 2>/dev/null || \
    awk '{printf "%.1fW\n", ($1 * $2) / 1000000000}' \
    /sys/class/power_supply/BAT*/voltage_now \
    /sys/class/power_supply/BAT*/current_now 2>/dev/null
