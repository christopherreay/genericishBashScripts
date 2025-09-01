#!/bin/bash

# Install ImageMagick
# Provides 'convert' command for image manipulation and analysis
# Required for mpv.bluetooth.wrapper ambient lighting detection

echo "Installing ImageMagick..."
sudo apt update
sudo apt install -y imagemagick

# Verify installation
if command -v convert &> /dev/null; then
    echo "✅ ImageMagick installed successfully"
    convert -version | head -2
else
    echo "❌ ImageMagick installation failed"
    exit 1
fi

echo "ImageMagick installation complete!"