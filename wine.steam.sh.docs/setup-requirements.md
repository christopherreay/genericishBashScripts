# Wine Steam Script Setup Requirements

## Overview
The `wine.steam.sh` script requires Wine with 32-bit support to run Steam and Windows games properly.

## Error Message
If you see this error when running the script:
```
it looks like wine32 is missing, you should install it.
multiarch needs to be enabled first.  as root, please
execute "dpkg --add-architecture i386 && apt-get update &&
apt-get install wine32:i386"
```

## Prerequisites Installation

### Automated Installation
Run the provided installation script:
```bash
./installation/newLinuxInstall/wine.install.with32bitSupport.sh
```

### Manual Installation
1. **Enable 32-bit architecture support:**
   ```bash
   sudo dpkg --add-architecture i386
   ```

2. **Update package lists:**
   ```bash
   sudo apt update
   ```

3. **Install Wine and components:**
   ```bash
   sudo apt install -y wine winetricks
   ```

4. **Install 32-bit Wine support:**
   ```bash
   # Try this first:
   sudo apt install -y wine32:i386
   
   # If that fails, Wine may already include 32-bit support
   # Verify with: wine --version
   ```

## Verification
After installation, test the script:
```bash
./wine.steam.sh --version
```

Should show Wine version information without errors.

## Script Details
- **WINEPREFIX**: `/torrents/christopher/games/wine-steam`
- **Purpose**: Launches Wine applications with Steam-specific Wine environment
- **Requirements**: Wine with 32-bit support for Windows game compatibility

## Troubleshooting

### Package Not Found
If `wine32:i386` is not available, modern Debian Wine packages may already include 32-bit support by default.

### Permission Issues
Ensure your user has access to the WINEPREFIX directory:
```bash
ls -la /torrents/christopher/games/wine-steam
```

### Steam Installation
To install Steam in Wine:
```bash
export WINEPREFIX="/torrents/christopher/games/wine-steam"
winetricks steam
```