# NVIDIA Driver Installation on Acer Nitro V15 (Debian 12)

## Hardware
- **GPU**: NVIDIA GeForce RTX 4060 Max-Q / Mobile
- **Bus ID**: 0000:01:00.0
- **Integrated**: Intel UHD Graphics (RPL-P)
- **Configuration**: Hybrid/Optimus setup

## Prerequisites (CRITICAL)

### 1. Setup GUI Sudo (Do This First!)
**CRITICAL:** Set up GUI sudo before repository changes to prevent blocking.

```bash
# Create askpass script (no sudo needed for user home)
mkdir -p ~/Scripts
echo '#!/bin/bash
/usr/bin/zenity --password --title="sudo"' > ~/Scripts/askpass.graphical
chmod +x ~/Scripts/askpass.graphical
export SUDO_ASKPASS=~/Scripts/askpass.graphical

# Test it works
sudo -A whoami  # Should show GUI prompt and return: root
```

### 2. Fix Repository Sources  
NVIDIA installation **will fail** without proper repository configuration:

```bash
# Add contrib and non-free to main sources
sudo -A sed -i 's/main$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list

# Add backports for newer drivers
echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" | sudo -A tee /etc/apt/sources.list.d/backports.list

# Update package lists
sudo -A apt update
```

### 3. Install Development Tools
```bash
sudo -A apt install build-essential dkms linux-headers-$(uname -r) -y
```

## Installation Process

### 1. Check GPU Compatibility
```bash
sudo apt install nvidia-detect -y
nvidia-detect
# Should show: "It is recommended to install the nvidia-driver package"
```

### 2. Install NVIDIA Drivers
```bash
# Install complete NVIDIA driver stack
sudo apt install nvidia-driver nvidia-settings -y
```

**Expected behavior:** Installation will show configuration dialogs about nouveau conflicts. This is normal - just acknowledge them.

### 3. Blacklist Nouveau Driver
```bash
# Prevent conflicts with nouveau (open-source driver)
sudo bash -c 'echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-nouveau.conf'
sudo bash -c 'echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf'

# Update initramfs to apply changes
sudo update-initramfs -u
```

### 4. Reboot System
```bash
sudo reboot
```

## Verification

### Check Driver Status
```bash
# Verify NVIDIA driver loaded
nvidia-smi
# Should show RTX 4060 GPU details and processes

# Check loaded modules
lsmod | grep nvidia
# Should show nvidia, nvidia_drm, nvidia_modeset, nvidia_uvm modules

# Verify nouveau is not loaded
lsmod | grep nouveau
# Should show no output
```

### Test GPU Switching

**Default (Intel GPU):**
```bash
glxinfo | grep "OpenGL renderer"
# Shows: Mesa Intel(R) Graphics (RPL-P)
```

**NVIDIA On-Demand:**
```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo | grep "OpenGL renderer"
# Shows: NVIDIA GeForce RTX 4060 Laptop GPU/PCIe/SSE2
```

## GPU Usage

### Power Management
- **Intel GPU**: Always active, handles desktop and low-power tasks
- **NVIDIA GPU**: Activates on-demand, automatically powers down when idle
- **Battery Life**: Intel GPU provides excellent battery life
- **Performance**: NVIDIA GPU provides high performance when needed

### Running Applications on NVIDIA

**Gaming:**
```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia steam
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia wine your_game.exe
```

**Creative Applications:**
```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia blender
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia davinci-resolve
```

**CUDA Computing:**
```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia python pytorch_script.py
```

## Configuration Tools

### NVIDIA Settings
```bash
# Launch NVIDIA control panel
nvidia-settings

# Launch with NVIDIA GPU context
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia nvidia-settings -c :8
```

### Monitor GPU Usage
```bash
# Real-time monitoring
watch nvidia-smi

# Check temperature and power
nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv
```

## Troubleshooting

### NVIDIA-SMI Fails After Installation
**Symptom:** `NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver`

**Causes:**
1. Nouveau driver still loaded (most common)
2. NVIDIA modules not properly built/loaded
3. Incomplete installation due to repository issues

**Solutions:**
```bash
# Check if nouveau is still loaded
lsmod | grep nouveau

# If nouveau is present, re-blacklist and reboot
sudo bash -c 'echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-nouveau.conf'
sudo bash -c 'echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf'
sudo update-initramfs -u
sudo reboot
```

### Installation Timeouts or Hangs
**Cause:** Missing contrib/non-free repositories causing dependency resolution failures

**Solution:** Ensure repositories are properly configured before installation (see Prerequisites)

### DKMS Build Failures
**Cause:** Missing kernel headers or build tools

**Solution:**
```bash
sudo apt install build-essential dkms linux-headers-$(uname -r) -y
sudo dkms autoinstall
```

## Performance Tips

### Laptop Mode (Default)
- Intel GPU handles desktop: excellent battery life
- NVIDIA GPU idles: minimal power consumption
- Applications automatically use appropriate GPU

### Force NVIDIA for Desktop (Not Recommended)
```bash
# Only if you need NVIDIA for desktop compositing
sudo prime-select nvidia  # If available
# Or edit xorg.conf manually
```

**Warning:** This significantly reduces battery life.

## Final Status
- ✅ **Hybrid GPU**: Intel + NVIDIA working correctly
- ✅ **Power Management**: Automatic GPU switching
- ✅ **Performance**: RTX 4060 available for demanding applications  
- ✅ **Battery Life**: Intel GPU handles desktop efficiently
- ✅ **Compatibility**: Works with Steam, Blender, CUDA applications