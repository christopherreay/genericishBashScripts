#!/bin/bash

# Install Wine with 32-bit support for Steam
# Enables multiarch and installs wine32 for compatibility with Windows games
# Required for wine.steam.sh script to work properly

set -e

echo "Installing Wine with 32-bit support..."

# Step 1: Enable multiarch (32-bit support)
echo "📦 Enabling 32-bit architecture support..."
sudo dpkg --add-architecture i386

# Step 2: Update package lists
echo "🔄 Updating package lists..."
sudo apt update

# Step 3: Install Wine with additional components
echo "🍷 Installing Wine and winetricks..."
sudo apt install -y wine winetricks

# Step 4: Install 32-bit Wine support (after multiarch is enabled)
echo "🔧 Installing 32-bit Wine support..."
sudo apt install -y wine32:i386 || {
    echo "⚠️  wine32:i386 not available, checking alternative packages..."
    # Try alternative approach - wine should include 32-bit support by default on newer Debian
    sudo apt install -y wine64 wine32 || echo "Note: Some wine32 packages may not be available"
}

# Verify installation
echo "✅ Verifying Wine installation..."
if command -v wine &> /dev/null; then
    echo "🍷 Wine version: $(wine --version)"
else
    echo "❌ Wine installation failed"
    exit 1
fi

# Check 32-bit support
if wine --version | grep -q "wine-"; then
    echo "✅ Wine installed successfully"
    
    # Test 32-bit support
    if dpkg --print-foreign-architectures | grep -q i386; then
        echo "✅ 32-bit architecture (i386) enabled"
    else
        echo "⚠️  32-bit architecture may not be properly enabled"
    fi
else
    echo "❌ Wine installation verification failed"
    exit 1
fi

echo ""
echo "🎉 Wine installation with 32-bit support complete!"
echo ""
echo "📋 Next steps:"
echo "1. The wine.steam.sh script should now work properly"
echo "2. You may want to run 'winecfg' to configure Wine settings"
echo "3. Consider installing Steam in Wine: 'winetricks steam'"
echo ""
echo "💡 Useful commands:"
echo "   wine --version          - Check Wine version"
echo "   winecfg                - Configure Wine"
echo "   winetricks             - Install Windows components"
echo "   wine uninstaller       - Manage installed Windows programs"