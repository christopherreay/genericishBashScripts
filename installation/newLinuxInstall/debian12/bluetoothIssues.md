# Bluetooth Issues on Acer Nitro V15 (Debian 12)

## Problem
MediaTek MT7922 wireless chip Bluetooth functionality fails to initialize on Debian 12 stable due to outdated firmware.

## Hardware Detection
```bash
# Bluetooth hardware is detected correctly
lsusb | grep -i wireless
# Shows: Bus 003 Device 003: ID 13d3:3606 IMC Networks Wireless_Device

# Bluetooth service runs but interface fails
systemctl status bluetooth  # Active (running)
hciconfig                   # Shows hci0 DOWN with 00:00:00:00:00:00 address

# Error in kernel logs
sudo dmesg | grep -i bluetooth
# Shows: Bluetooth: hci0: Opcode 0x0c03 failed: -110 (timeout error)
```

## Root Cause
- WiFi portion of MT7922 works fine (uses mt7921e driver)
- Bluetooth portion requires newer **kernel drivers** more than firmware
- Debian 12 stable ships kernel 6.1.x which has incomplete MT7922 Bluetooth support
- Kernel 6.12.x has proper MT7922 Bluetooth drivers that work with existing firmware

## Attempted Solutions
1. ✅ Bluetooth service is running
2. ✅ Hardware detected correctly  
3. ✅ Modules loaded (btusb, btmtk, bluetooth)
4. ✅ Firmware files present in /lib/firmware/mediatek/
5. ✅ Restarted services and reloaded modules
6. ✅ Added backports repository - no newer firmware available
7. ❌ `hciconfig hci0 up` fails with timeout

## Working Solutions

### ✅ Option 1: Kernel Upgrade from Backports (RECOMMENDED - TESTED WORKING)
**This solution works perfectly!** The newer 6.12 kernel has proper MT7922 Bluetooth drivers:

```bash
# Ensure backports repository is configured
echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt update

# Install newer kernel
sudo apt install -t bookworm-backports linux-image-amd64 linux-headers-amd64 -y

# Reboot to new kernel
sudo reboot
```

**After reboot, Bluetooth works immediately:**
```bash
uname -r
# Shows: 6.12.38+deb12-amd64 (or similar 6.12.x)

hciconfig
# Shows: hci0 UP RUNNING with valid BD Address like 1C:CE:51:25:09:0C

sudo bluetoothctl scan on
# Successfully scans for devices
```

### Option 2: Upgrade to Debian Testing/Sid
Alternative comprehensive fix if you want cutting-edge packages:
```bash
# Backup current sources
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Edit sources to point to testing
sudo nano /etc/apt/sources.list
# Replace 'bookworm' with 'testing' or 'sid'

# Update and upgrade (CAREFUL - this is a major system change)
sudo apt update && sudo apt full-upgrade
```

### Option 3: External USB Bluetooth Adapter
Only needed if you don't want to upgrade kernel:
```bash
# Disable internal Bluetooth to avoid conflicts
echo 'blacklist btusb' | sudo tee -a /etc/modprobe.d/blacklist-internal-bt.conf
```

## Recommendation
For a fresh Debian install on new hardware like Acer Nitro V15, consider starting with Debian testing instead of stable to get better hardware compatibility.

## Final Status
- WiFi: ✅ Working perfectly  
- Bluetooth: ✅ **FIXED** with kernel 6.12 upgrade from backports
- Trackpad: ✅ Fixed with configuration changes
- Graphics: ✅ Both Intel and NVIDIA working with hybrid switching

**Time to fix:** ~10 minutes (kernel install + reboot)