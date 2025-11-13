#!/bin/bash

# Create udev rule to disable autosuspend for NetGear AirCard LB1120
# Prevents USB disconnect/reconnect cycling that causes system freezes
# Device: NetGear AirCard LB1120 (vendor 0846, product 68e1)

echo "Setting up udev rule for AirCard autosuspend fix..."

# Create udev rule
echo "📝 Creating udev rule..."
cat > /tmp/50-aircard-no-autosuspend.rules << 'EOF'
# Disable autosuspend for NetGear AirCard LB1120 (vendor 0846, product 68e1)
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0846", ATTR{idProduct}=="68e1", ATTR{power/control}="on"
EOF

# Install rule
echo "📦 Installing rule to /etc/udev/rules.d/..."
sudo cp /tmp/50-aircard-no-autosuspend.rules /etc/udev/rules.d/
sudo chmod 644 /etc/udev/rules.d/50-aircard-no-autosuspend.rules

# Reload udev rules
echo "⚙️  Reloading udev rules..."
sudo udevadm control --reload-rules

# Verify installation
if [ -f /etc/udev/rules.d/50-aircard-no-autosuspend.rules ]; then
    echo "✅ Udev rule installed successfully"
    echo "📍 Rule location: /etc/udev/rules.d/50-aircard-no-autosuspend.rules"
    echo "📄 Rule content:"
    cat /etc/udev/rules.d/50-aircard-no-autosuspend.rules
else
    echo "❌ Rule installation failed"
    exit 1
fi

# Clean up
rm -f /tmp/50-aircard-no-autosuspend.rules

# Check if device is currently connected
echo ""
if lsusb | grep -q "0846:68e1"; then
    echo "📱 AirCard is currently connected"
    echo "⚠️  Replug the device for the rule to take effect"
else
    echo "📱 AirCard not currently connected"
    echo "📝 Rule will apply automatically when device is plugged in"
fi

echo ""
echo "✅ AirCard autosuspend fix setup complete!"
