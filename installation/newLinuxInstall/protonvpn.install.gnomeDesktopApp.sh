#!/bin/bash

# Install ProtonVPN GNOME Desktop App on Debian
# Based on official installation guide: https://protonvpn.com/support/official-linux-vpn-debian/
# 
# This script installs the official ProtonVPN desktop application for GNOME
# Includes repository setup and system tray integration

set -e

echo "Installing ProtonVPN GNOME Desktop App..."

# Update package list
echo "Updating package list..."
sudo apt update

# Step 1: Download ProtonVPN repository configuration
echo "Downloading ProtonVPN repository configuration..."
cd /tmp
wget -O protonvpn-stable-release.deb https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb

# Step 2: Install ProtonVPN repository
echo "Installing ProtonVPN repository..."
sudo dpkg -i ./protonvpn-stable-release.deb
sudo apt update

# Step 3: Install ProtonVPN GNOME desktop app
echo "Installing ProtonVPN GNOME desktop app..."
sudo apt install -y proton-vpn-gnome-desktop

# Step 4: Install system tray support (optional but recommended)
echo "Installing system tray integration..."
sudo apt install -y libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator

# Clean up downloaded file
rm -f /tmp/protonvpn-stable-release.deb

# Check installation
if command -v protonvpn-app &> /dev/null; then
    echo "✅ ProtonVPN installed successfully"
    echo "📍 Executable: $(which protonvpn-app)"
else
    echo "❌ ProtonVPN installation may have failed"
    exit 1
fi

echo ""
echo "🎉 ProtonVPN installation complete!"
echo ""
echo "📋 Next steps:"
echo "1. Restart your computer to ensure all components are loaded"
echo "2. Open the 'Extensions' app"
echo "3. Make sure 'Ubuntu AppIndicators' extension is enabled"
echo "4. Launch ProtonVPN from your applications menu"
echo ""
echo "📄 Official guide: https://protonvpn.com/support/official-linux-vpn-debian/"
echo ""
echo "⚠️  Note: This app officially supports Debian with GNOME."
echo "   It may work on other Debian-based distros but they're not officially supported."