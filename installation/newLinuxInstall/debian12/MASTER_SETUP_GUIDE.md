# Complete Acer Nitro V15 Debian 12 Setup Guide

## Overview
This guide sets up all hardware drivers for Acer Nitro V15 on a fresh Debian 12 installation in the optimal order to avoid common pitfalls.

**Hardware Status After Setup:**
- ✅ Trackpad: Right/middle click working
- ✅ Bluetooth: MediaTek MT7922 fully functional  
- ✅ Graphics: Intel + NVIDIA hybrid with switching
- ✅ WiFi: Working (usually works out of box)

**Total Time:** ~30-45 minutes + 1 reboot

---

## Phase 1: System Prerequisites (Do This FIRST!)

### 1.1 Setup GUI Sudo (Do This First!)
**CRITICAL:** Set up GUI sudo before any repository changes to prevent terminal blocking.

**Method 1: Create askpass script manually**
```bash
# Create directory (no sudo needed for user home)
mkdir -p ~/Scripts

# Create the askpass script
cat > ~/Scripts/askpass.graphical << 'EOF'
#!/bin/bash
/usr/bin/zenity --password --title="sudo"
EOF

# Make executable
chmod +x ~/Scripts/askpass.graphical

# Set environment variable for current session
export SUDO_ASKPASS=~/Scripts/askpass.graphical

# Add to ~/.bashrc for future sessions
echo 'export SUDO_ASKPASS=~/Scripts/askpass.graphical' >> ~/.bashrc
```

**Method 2: Copy from this documentation**
If you have this documentation folder on a USB drive:
```bash
mkdir -p ~/Scripts
# Copy the provided askpass script
cp ~/Scripts/installation/newLinuxInstall/debian12/askpass.graphical ~/Scripts/
# OR from USB: cp /media/usb/Scripts/installation/newLinuxInstall/debian12/askpass.graphical ~/Scripts/
chmod +x ~/Scripts/askpass.graphical
export SUDO_ASKPASS=~/Scripts/askpass.graphical
```

**Test sudo works:**
```bash
# This should show a GUI password prompt
sudo -A whoami
# Should return: root
```

### 1.2 Fix Repository Sources
**CRITICAL:** Debian installer often sets up incomplete sources.list

```bash
# Check current sources
cat /etc/apt/sources.list

# Fix sources to include contrib, non-free, non-free-firmware
sudo -A sed -i 's/main$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list

# Add backports (essential for newer hardware)  
echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" | sudo -A tee /etc/apt/sources.list.d/backports.list

# Update package lists
sudo -A apt update
```

### 1.3 Install Essential Development Tools
```bash
sudo -A apt install build-essential dkms linux-headers-$(uname -r) -y
```

---

## Phase 2: Kernel Upgrade (Fixes Most Hardware Issues)

### 2.1 Install Newer Kernel from Backports
The 6.12 kernel has much better hardware support than default 6.1:

```bash
# Install newer kernel (fixes MediaTek Bluetooth, improves NVIDIA support)
sudo -A apt install -t bookworm-backports linux-image-amd64 linux-headers-amd64 -y

# DO NOT REBOOT YET - install other drivers first
```

---

## Phase 3: Graphics Drivers

### 3.1 Install Required Tools
```bash
sudo -A apt install mesa-utils xinput libinput-tools evtest -y
```

### 3.2 Install NVIDIA Drivers
```bash
# Check GPU compatibility
sudo -A apt install nvidia-detect -y
nvidia-detect

# Install NVIDIA drivers (now works because repos are fixed)
sudo -A apt install nvidia-driver nvidia-settings -y

# Blacklist nouveau (prevents conflicts)
sudo -A bash -c 'echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-nouveau.conf'
sudo -A bash -c 'echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf'

# Update initramfs
sudo -A update-initramfs -u
```

---

## Phase 4: Trackpad Configuration

### 4.1 Diagnose Issue
```bash
# Check for PixArt clickpad bug
sudo -A libinput list-devices | grep -A 20 -i touchpad
# Look for: "clickpad advertising right button" warning
```

### 4.2 Fix Trackpad Buttons
```bash
# Configure GNOME touchpad settings
gsettings set org.gnome.desktop.peripherals.touchpad click-method 'areas'
gsettings set org.gnome.desktop.peripherals.touchpad middle-click-emulation true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
```

**Usage After Fix:**
- Left click: Normal tap/click anywhere
- Right click: Click bottom-right corner of trackpad  
- Middle click: Two-finger simultaneous click
- Scroll: Two-finger scroll

---

## Phase 5: Reboot and Verify

### 5.1 Reboot System
```bash
sudo -A reboot
```

### 5.2 Verify All Hardware

**Check Kernel:**
```bash
uname -r
# Should show: 6.12.38+deb12-amd64 (or similar 6.12.x)
```

**Check NVIDIA:**
```bash
nvidia-smi
# Should show RTX 4060 GPU active
```

**Check Bluetooth:**
```bash
hciconfig
# Should show hci0 UP RUNNING with valid BD Address
sudo bluetoothctl scan on  # Test scanning
```

**Check GPU Switching:**
```bash
# Default Intel rendering
glxinfo | grep "OpenGL renderer"
# Shows: Mesa Intel(R) Graphics (RPL-P)

# NVIDIA on-demand rendering
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo | grep "OpenGL renderer"  
# Shows: NVIDIA GeForce RTX 4060 Laptop GPU
```

**Test Trackpad:**
- Right-click in bottom-right corner
- Middle-click with two fingers
- Two-finger scroll

---

## GPU Usage Examples

**Battery Saving (Default):** All apps use Intel GPU automatically

**High Performance:** Prefix commands with NVIDIA offload:
```bash
# Gaming
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia steam

# Video editing  
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia davinci-resolve

# 3D modeling
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia blender
```

---

## Troubleshooting

### If NVIDIA doesn't work after reboot:
```bash
# Check if nouveau is still loaded
lsmod | grep nouveau
# If yes, it wasn't properly blacklisted

# Re-run blacklist commands and update initramfs
sudo -A bash -c 'echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-nouveau.conf'
sudo -A update-initramfs -u
sudo -A reboot
```

### If Bluetooth still doesn't work:
```bash
# Check kernel version
uname -r
# Must be 6.12.x for MediaTek MT7922 support

# Check dmesg for errors
sudo -A dmesg | grep -i bluetooth
```

### If trackpad buttons don't work:
```bash
# Verify settings applied
gsettings get org.gnome.desktop.peripherals.touchpad click-method
# Should return: 'areas'
```

---

## Why This Order Works

1. **Fix repos first:** Prevents dependency hell and timeouts
2. **Setup askpass early:** Prevents sudo blocking operations  
3. **Upgrade kernel early:** Fixes hardware compatibility before configuring
4. **Install all drivers before reboot:** More efficient than multiple reboots
5. **Configure software after hardware:** Ensures drivers are available

**Time Saved:** Following this order saves ~2 hours vs the trial-and-error approach we used initially.