#!/bin/bash

# Install i3blocks for better status bar with custom power monitoring
# Replaces i3status with more flexible block-based status bar
# Includes custom battery power display script

echo "Installing i3blocks..."
sudo apt update
sudo apt install -y i3blocks

# Verify installation
if command -v i3blocks &> /dev/null; then
    echo "✅ i3blocks installed successfully"
    echo "📍 i3blocks version: $(i3blocks -v 2>&1 | head -1)"
else
    echo "❌ i3blocks installation failed"
    exit 1
fi

# Set up configuration directories
echo "📁 Creating configuration directories..."
mkdir -p ~/.config/i3blocks/scripts
mkdir -p ~/Scripts/i3blocks

# Create battery power monitoring script
echo "🔋 Setting up battery power monitoring script..."
cat > ~/Scripts/i3blocks/battery-power << 'EOF'
#!/bin/bash
# Display battery power consumption in watts

BAT_PATH="/sys/class/power_supply/BAT0"

if [ ! -d "$BAT_PATH" ]; then
    echo "No battery"
    exit 0
fi

STATUS=$(cat "$BAT_PATH/status")
VOLTAGE=$(cat "$BAT_PATH/voltage_now")
CURRENT=$(cat "$BAT_PATH/current_now")
CAPACITY=$(cat "$BAT_PATH/capacity")

# Calculate watts (voltage * current / 1000000000)
WATTS=$(awk "BEGIN {printf \"%.1f\", ($VOLTAGE * $CURRENT) / 1000000000}")

# Remove negative sign for display
WATTS_ABS=$(echo $WATTS | tr -d '-')

# Choose icon based on status
if [ "$STATUS" = "Charging" ]; then
    ICON="⚡"
elif [ "$STATUS" = "Discharging" ]; then
    ICON="🔋"
else
    ICON="🔌"
fi

# Full text
echo "$ICON $CAPACITY% ${WATTS_ABS}W"
# Short text
echo "$CAPACITY%"
EOF

chmod +x ~/Scripts/i3blocks/battery-power

# Create i3blocks configuration
echo "⚙️  Creating i3blocks configuration..."
cat > ~/Scripts/i3blocks/config << 'EOF'
# i3blocks configuration

[battery-power]
command=$SCRIPT_DIR/battery-power
interval=5
markup=pango

[time]
command=date '+%Y-%m-%d %H:%M:%S'
interval=1
EOF

# Create symlinks
echo "🔗 Creating symlinks..."
ln -sf ~/Scripts/i3blocks/battery-power ~/.config/i3blocks/scripts/battery-power
ln -sf ~/Scripts/i3blocks/config ~/.config/i3blocks/config

echo "📝 To enable i3blocks, update your i3 config:"
echo "    Change 'status_command i3status' to 'status_command i3blocks'"
echo "    Then reload i3: i3-msg reload"
echo ""
echo "✅ i3blocks installation complete!"
