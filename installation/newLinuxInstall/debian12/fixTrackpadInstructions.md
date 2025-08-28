# Fix Trackpad Right and Middle Click on Acer Nitro V15 (Debian 12)

## Problem
The PixArt touchpad (PIXA3848:00 093A:3848) on Acer Nitro V15 has a kernel bug where it incorrectly advertises having physical buttons when it's actually a clickpad. This causes right and middle click to not work properly.

## Diagnosis
Check if you have this issue:
```bash
sudo dmesg | grep -i touchpad
# Look for: "clickpad advertising right button" error

sudo libinput list-devices | grep -A 20 -i touchpad
# Shows the kernel bug warning
```

## Solution
Configure GNOME to use proper clickpad settings:

```bash
# Set click method to button areas (enables right-click in bottom-right corner)
gsettings set org.gnome.desktop.peripherals.touchpad click-method 'areas'

# Enable middle-click emulation (two-finger click for middle click)
gsettings set org.gnome.desktop.peripherals.touchpad middle-click-emulation true

# Optional: Enable tap-to-click for convenience
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
```

## Usage After Fix
- **Left click**: Single tap or press anywhere on trackpad
- **Right click**: Click in the bottom-right corner of the trackpad
- **Middle click**: Click with two fingers simultaneously
- **Scroll**: Two-finger scroll (should already work)

## Verification
Check settings were applied:
```bash
gsettings get org.gnome.desktop.peripherals.touchpad click-method
# Should return: 'areas'

gsettings get org.gnome.desktop.peripherals.touchpad middle-click-emulation  
# Should return: true
```

## Alternative: Upgrade to Newer Kernel
This bug is fixed in newer kernels. Consider upgrading to Debian testing/unstable or using backports for a newer kernel if you want the proper fix rather than the workaround.

---

## Advanced: Restoring Three-Finger Workspace Switching

**Problem:** After fixing trackpad buttons, three-finger workspace switching may stop working due to gesture conflicts, especially after kernel upgrades.

### Solution: Install libinput-gestures

**1. Install Prerequisites:**
```bash
sudo -A apt install git wmctrl -y
sudo -A gpasswd -a $USER input
```

**2. Install libinput-gestures:**
```bash
cd /tmp
git clone https://github.com/bulletmark/libinput-gestures.git
cd libinput-gestures
sudo -A make install
```

**3. Configure User Gestures:**
```bash
# Enable autostart
libinput-gestures-setup autostart

# Copy default config
cp /etc/libinput-gestures.conf ~/.config/libinput-gestures.conf

# Edit configuration for workspace switching
nano ~/.config/libinput-gestures.conf
```

**4. Add/Edit Gesture Configuration:**
Add these lines to `~/.config/libinput-gestures.conf`:
```bash
# Workspace switching left/right with 3 fingers  
gesture swipe left 3 _internal ws_down
gesture swipe right 3 _internal ws_up

# Comment out browser navigation gestures (if present):
# gesture swipe left	xdotool key alt+Right
# gesture swipe right	xdotool key alt+Left
```

**5. Start Gestures Service:**
```bash
# Note: User must be logged out/in after adding to input group, or use:
newgrp input

# Start the service
libinput-gestures-setup start
```

### Final Configuration

**Trackpad functionality after complete setup:**
- **Left click**: Single tap anywhere on trackpad
- **Right click**: Click bottom-right corner of trackpad (due to 'areas' method)
- **Middle click**: Two-finger simultaneous click
- **Three-finger swipe left**: Previous workspace
- **Three-finger swipe right**: Next workspace  
- **Two-finger scroll**: Vertical scrolling
- **No browser gestures**: Disabled to prevent conflicts

### Troubleshooting

**If gestures don't work:**
```bash
# Check service status
libinput-gestures-setup status

# Restart service
libinput-gestures-setup restart

# Check user is in input group
groups | grep input
```

**If right-click stops working:**
```bash
# Ensure proper click method for button areas
gsettings set org.gnome.desktop.peripherals.touchpad click-method 'areas'
gsettings set org.gnome.desktop.peripherals.touchpad middle-click-emulation true
```

**Service Management:**
```bash
# Stop gestures
libinput-gestures-setup stop

# Disable autostart
libinput-gestures-setup autostop

# Check logs
libinput-gestures -d
```

This solution provides both proper button functionality AND three-finger workspace switching on modern kernels where native gesture support may be limited.