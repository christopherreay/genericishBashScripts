#!/bin/bash

# Install brightnessctl
# Provides brightness control for laptop displays
# Required for brightnessUpDown.sh script

echo "Installing brightnessctl..."
sudo apt update
sudo apt install -y brightnessctl

# Verify installation
if command -v brightnessctl &> /dev/null; then
    echo "✅ brightnessctl installed successfully"
    echo "📍 brightnessctl version: $(brightnessctl --version)"
    
    # Show available devices
    echo "📱 Available brightness devices:"
    brightnessctl --list 2>/dev/null || echo "No brightness devices detected (may be desktop system)"
    
    # Set up user permissions if needed
    echo "📝 Adding user to video group for brightness control..."
    sudo usermod -a -G video $USER
    echo "⚠️  You may need to log out and back in for group changes to take effect"
else
    echo "❌ brightnessctl installation failed"
    exit 1
fi

echo "brightnessctl installation complete!"