#!/bin/bash

# Install qBittorrent Jackett plugin with dependencies
# Provides torrent search through multiple indexers via Jackett
# Installs as USER service, not root

echo "Installing qBittorrent Jackett plugin setup..."

# Update package list
sudo apt update

# Install .NET 8 Runtime (required for Jackett)
echo "Installing .NET 8 Runtime..."
if ! command -v dotnet &> /dev/null; then
    wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y dotnet-runtime-8.0
else
    echo ".NET Runtime already installed"
fi

# Check if qBittorrent is installed
if ! command -v qbittorrent &> /dev/null; then
    echo "Warning: qBittorrent not found. Please install it separately."
    echo "Run: sudo apt install qbittorrent"
else
    echo "qBittorrent found"
fi

# Download and install Jackett in user's home directory
echo "Installing Jackett..."
JACKETT_VERSION="v0.22.2360"
JACKETT_URL="https://github.com/Jackett/Jackett/releases/download/${JACKETT_VERSION}/Jackett.Binaries.LinuxAMDx64.tar.gz"
JACKETT_DIR="$HOME/.local/share/Jackett"

mkdir -p "$JACKETT_DIR"
cd "$JACKETT_DIR"
wget -O jackett.tar.gz "$JACKETT_URL"
tar -xzf jackett.tar.gz --strip-components=1
rm jackett.tar.gz

# Make jackett executable
chmod +x "$JACKETT_DIR/jackett"

# Create user systemd service for Jackett
echo "Creating Jackett user systemd service..."
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/jackett.service << EOF
[Unit]
Description=Jackett Daemon
After=network.target

[Service]
Type=simple
WorkingDirectory=$JACKETT_DIR
ExecStart=$JACKETT_DIR/jackett --NoUpdates
Restart=always
RestartSec=5
TimeoutStopSec=20

[Install]
WantedBy=default.target
EOF

# Enable and start Jackett user service
systemctl --user daemon-reload
systemctl --user enable jackett
systemctl --user start jackett

echo "Waiting for Jackett to start..."
sleep 10

# Check if Jackett is running
if systemctl --user is-active --quiet jackett; then
    echo "Jackett is running on http://localhost:9117"
else
    echo "Warning: Jackett may not have started properly"
    systemctl --user status jackett
fi

# Create qBittorrent configuration directory
QBIT_CONFIG_DIR="$HOME/.local/share/qBittorrent"
QBIT_SEARCH_DIR="$QBIT_CONFIG_DIR/nova3/engines"
mkdir -p "$QBIT_SEARCH_DIR"

# Download Jackett plugin for qBittorrent
echo "Installing qBittorrent Jackett plugin..."
wget -O "$QBIT_SEARCH_DIR/jackett.py" \
    "https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/jackett.py"

# Extract API key from Jackett config and update qBittorrent config
echo "Configuring API key..."

# Function to extract API key from config file
extract_api_key() {
    if [ -f "$HOME/.config/Jackett/ServerConfig.json" ]; then
        grep -oP '"APIKey"\s*:\s*"[^"]*"' "$HOME/.config/Jackett/ServerConfig.json" | grep -oP '"[^"]*"$' | tr -d '"'
    fi
}

# Function to extract API key from web interface
extract_api_key_from_web() {
    if command -v curl &> /dev/null; then
        curl -s "http://localhost:9117/UI/Dashboard" 2>/dev/null | grep -oP 'api_key["\s]*[:=]["\s]*[a-z0-9]{32}' | grep -oP '[a-z0-9]{32}' | head -1
    elif command -v wget &> /dev/null; then
        wget -qO- "http://localhost:9117/UI/Dashboard" 2>/dev/null | grep -oP 'api_key["\s]*[:=]["\s]*[a-z0-9]{32}' | grep -oP '[a-z0-9]{32}' | head -1
    fi
}

# Wait for Jackett web interface to be ready and trigger API key generation
echo "Waiting for Jackett to generate API key..."
API_KEY=""
for i in {1..60}; do
    # First, try to access the Dashboard page to trigger API key generation
    if command -v curl &> /dev/null; then
        curl -s "http://localhost:9117/UI/Dashboard" >/dev/null 2>&1
    elif command -v wget &> /dev/null; then
        wget -qO- "http://localhost:9117/UI/Dashboard" >/dev/null 2>&1
    fi
    
    # Wait a moment for the config to be written
    sleep 1
    
    # Now check the config file for the API key
    API_KEY=$(extract_api_key)
    
    if [ -n "$API_KEY" ] && [ ${#API_KEY} -eq 32 ]; then
        echo "Found API key: $API_KEY"
        break
    fi
    
    if [ $((i % 10)) -eq 0 ]; then
        echo "Still waiting for API key... ($i/60)"
        if [ -f "$HOME/.config/Jackett/ServerConfig.json" ]; then
            echo "Config file exists, checking contents..."
        else
            echo "Config file not yet created"
        fi
    fi
    sleep 2
done

if [ -n "$API_KEY" ] && [ ${#API_KEY} -eq 32 ]; then
    # Create configuration file with real API key
    cat > "$QBIT_SEARCH_DIR/jackett.json" << EOF
{
    "api_key": "$API_KEY",
    "url": "http://127.0.0.1:9117",
    "tracker_first": false,
    "thread_count": 20
}
EOF
    echo "Configuration updated with API key: $API_KEY"
    echo "Testing API key..."
    
    # Test the API key works
    if command -v curl &> /dev/null; then
        TEST_RESULT=$(curl -s "http://localhost:9117/api/v2.0/indexers/all/results/torznab/api?apikey=$API_KEY&t=indexers&configured=true" 2>/dev/null)
        if echo "$TEST_RESULT" | grep -q "indexer"; then
            echo "✅ API key test successful!"
        else
            echo "⚠️  API key test failed, but configuration created"
        fi
    fi
else
    echo "❌ Could not extract API key after 2 minutes"
    echo "Creating template config - you'll need to manually update the API key"
    echo "1. Open http://localhost:9117"
    echo "2. Copy the API key from the dashboard"
    echo "3. Edit $QBIT_SEARCH_DIR/jackett.json"
    
    cat > "$QBIT_SEARCH_DIR/jackett.json" << EOF
{
    "api_key": "YOUR_API_KEY_HERE",
    "url": "http://127.0.0.1:9117",
    "tracker_first": false,
    "thread_count": 20
}
EOF
fi

echo ""
echo "Installation complete!"
echo ""
echo "Jackett installed as USER service (not root):"
echo "- Installation: $JACKETT_DIR"
echo "- Config: ~/.config/Jackett/"
echo "- Web interface: http://localhost:9117"
echo ""
echo "User service commands:"
echo "  systemctl --user start jackett"
echo "  systemctl --user stop jackett"
echo "  systemctl --user status jackett"
echo ""
echo "qBittorrent plugin:"
echo "  Plugin: $QBIT_SEARCH_DIR/jackett.py"
echo "  Config: $QBIT_SEARCH_DIR/jackett.json"
echo ""
echo "Next steps:"
echo "1. Open http://localhost:9117 to add indexers"
echo "2. Restart qBittorrent to load the plugin"