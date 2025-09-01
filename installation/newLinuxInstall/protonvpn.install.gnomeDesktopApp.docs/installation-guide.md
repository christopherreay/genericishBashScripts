# ProtonVPN GNOME Desktop App Installation

## Overview
Installs the official ProtonVPN desktop application for GNOME-based Debian systems.

## Official Documentation
- **Source**: https://protonvpn.com/support/official-linux-vpn-debian/
- **Repository**: https://repo.protonvpn.com/debian/

## Installation Steps

### 1. Repository Setup
```bash
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb
sudo apt update
```

### 2. Install Desktop App
```bash
sudo apt install proton-vpn-gnome-desktop
```

### 3. System Tray Integration (Recommended)
```bash
sudo apt install libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator
```

## Post-Installation Setup

### Enable System Tray (Debian 11+)
1. **Restart** your computer
2. Open **Extensions** app
3. Enable **Ubuntu AppIndicators** extension
4. Launch ProtonVPN from applications menu

## System Requirements
- **Officially Supported**: Latest stable Debian with GNOME
- **May Work**: Other Debian-based distributions (not officially supported)
- **Desktop Environment**: GNOME (required for this version)

## Package Details
- **Main Package**: `proton-vpn-gnome-desktop`
- **Repository Package**: `protonvpn-stable-release_1.0.8_all.deb`
- **Tray Support**: AppIndicator libraries and GNOME Shell extension

## Usage
After installation and setup:
1. Launch **ProtonVPN** from applications menu
2. Sign in with your ProtonVPN account credentials
3. Connect to VPN servers through the GUI

## Troubleshooting
- If system tray icon doesn't appear, ensure AppIndicators extension is enabled
- Restart GNOME Shell: `Alt+F2` → type `r` → Enter
- Check Extensions app for Ubuntu AppIndicators toggle