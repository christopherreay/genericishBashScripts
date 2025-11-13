#!/bin/bash

# Master installation script for laptop power management and hibernation fixes
# Installs and configures:
#   - i3blocks with battery power monitoring
#   - Power management scripts (low-power and normal modes)
#   - Hibernation fix for Nvidia GPU and Bluetooth
#   - AirCard USB autosuspend fix

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "Laptop Power Management & Hibernation Setup"
echo "================================================"
echo ""

# Function to run script and check result
run_script() {
    local script=$1
    local description=$2

    echo "🚀 Running: $description"
    echo "   Script: $script"

    if [ -f "$SCRIPT_DIR/$script" ]; then
        bash "$SCRIPT_DIR/$script"
        if [ $? -eq 0 ]; then
            echo "✅ $description - Complete"
        else
            echo "❌ $description - Failed"
            return 1
        fi
    else
        echo "❌ Script not found: $script"
        return 1
    fi

    echo ""
}

# Install i3blocks
run_script "apt.install.i3blocks.sh" "i3blocks Installation"

# Set up power management scripts
run_script "power.management.setup.sh" "Power Management Scripts"

# Install hibernation fix
run_script "hibernate.fix.nvidia.bluetooth.sh" "Hibernation Fix Service"

# Install AirCard udev rule
run_script "udev.disable.aircard.autosuspend.sh" "AirCard Autosuspend Fix"

echo "================================================"
echo "✅ All installations complete!"
echo "================================================"
echo ""
echo "📝 Next steps:"
echo "   1. Update i3 config to use i3blocks:"
echo "      Change 'status_command i3status' to 'status_command i3blocks'"
echo "      Then: i3-msg reload"
echo ""
echo "   2. Test power management:"
echo "      Low power:  ~/Scripts/power/low-power-mode.sh"
echo "      Normal:     ~/Scripts/power/normal-power-mode.sh"
echo ""
echo "   3. Hibernation fix is already enabled (will activate on next sleep/hibernate)"
echo ""
echo "   4. Replug AirCard if connected for udev rule to take effect"
echo ""
