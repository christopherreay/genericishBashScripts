#!/bin/bash

# Install systemd service to fix Nvidia GPU and Bluetooth power management around hibernation
# Prevents power state issues that cause system pausing after resume
# Sets devices to 'on' before hibernation, restores to 'auto' after resume

echo "Setting up hibernation fix for Nvidia GPU and Bluetooth..."

# Create systemd service
echo "📝 Creating systemd service..."
cat > /tmp/nvidia-hibernate-fix.service << 'EOF'
[Unit]
Description=Fix Nvidia GPU and Bluetooth power management around hibernation
Before=sleep.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'echo on > /sys/bus/pci/devices/0000:01:00.0/power/control'
ExecStart=/bin/sh -c 'echo on > /sys/bus/usb/devices/3-10/power/control'
ExecStop=/bin/sh -c 'echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control'
ExecStop=/bin/sh -c 'echo auto > /sys/bus/usb/devices/3-10/power/control'

[Install]
WantedBy=sleep.target
EOF

# Install service
echo "📦 Installing service to /etc/systemd/system/..."
sudo cp /tmp/nvidia-hibernate-fix.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/nvidia-hibernate-fix.service

# Reload systemd and enable service
echo "⚙️  Enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable nvidia-hibernate-fix.service

# Verify installation
if systemctl is-enabled nvidia-hibernate-fix.service &> /dev/null; then
    echo "✅ nvidia-hibernate-fix.service installed and enabled successfully"
    echo "📍 Service status:"
    systemctl status nvidia-hibernate-fix.service --no-pager | head -10
else
    echo "❌ Service installation failed"
    exit 1
fi

# Clean up
rm -f /tmp/nvidia-hibernate-fix.service

echo ""
echo "✅ Hibernation fix setup complete!"
echo "📝 This service will:"
echo "   • Set GPU and Bluetooth to 'on' before hibernation"
echo "   • Restore them to 'auto' after resume"
echo "   • Prevent system pausing issues after hibernation"
