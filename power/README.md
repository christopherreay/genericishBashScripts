# Power Management Scripts

## Scripts

### `low-power-mode.sh`
Maximize battery life by enabling aggressive power saving on all components.

**Settings:**
- CPU governor: `powersave` (all cores)
- GPU: Runtime PM enabled (`auto`)
- All PCI devices: Runtime PM enabled where supported
- USB devices: Autosuspend enabled (except AirCard via udev rule)
- WiFi: Power save mode on
- SATA: Aggressive link power management (`med_power_with_dipm`)
- Audio: Power saving enabled (1 second timeout)

**Usage:**
```bash
~/Scripts/power/low-power-mode.sh
```

**Expected power draw:** ~15-20W (depending on workload and screen brightness)

### `normal-power-mode.sh`
Balanced power management - good battery life with responsive performance.

**Settings:**
- Same as low-power-mode (both use efficient power management)
- The main difference is that you control screen brightness separately

**Usage:**
```bash
~/Scripts/power/normal-power-mode.sh
```

**Expected power draw:** ~19-25W (depending on workload and screen brightness)

## Components Managed

### CPU Frequency Scaling
- **Governor:** `powersave` - Dynamically adjusts frequency based on load
- **Alternative governors:** `performance` (max frequency), `schedutil` (scheduler-based)
- **Check current:** `cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`

### GPU (Nvidia RTX 2050)
- **Runtime PM:** Automatically suspends when idle
- **Location:** `/sys/bus/pci/devices/0000:01:00.0/power/control`
- **Options:** `on` (always powered), `auto` (runtime PM)

### USB Devices
- **Autosuspend:** Devices suspend after idle timeout
- **Exception:** AirCard (0846:68e1) always stays powered via udev rule
- **Global setting:** Controlled via `usbcore.autosuspend` kernel parameter (removed to enable autosuspend)

### WiFi
- **Power save:** Reduces transmission power when possible
- **Command:** `iw dev wlp62s0 set power_save on/off`

### SATA Link Power Management
- **Modes:**
  - `max_performance` - No power saving
  - `medium_power` - Balanced
  - `med_power_with_dipm` - Aggressive saving (DIPM)
  - `min_power` - Maximum saving (may cause issues)

### Audio (Intel HDA)
- **Power save:** Codec powers down after 1 second of silence
- **Parameter:** `/sys/module/snd_hda_intel/parameters/power_save`

## Hibernation Power Management

The `nvidia-hibernate-fix.service` systemd service manages power during hibernation:
- **Before hibernation:** Sets GPU and Bluetooth to `on` to prevent power state issues
- **After resume:** Restores devices to `auto` for normal power management

**Service file:** `/etc/systemd/system/nvidia-hibernate-fix.service`

## Current Power Draw

Check current battery power consumption:
```bash
# Method 1: Direct power reading (if supported)
cat /sys/class/power_supply/BAT*/power_now

# Method 2: Calculate from voltage and current
awk '{printf "%.1fW\n", ($1 * $2) / 1000000000}' \
    /sys/class/power_supply/BAT*/voltage_now \
    /sys/class/power_supply/BAT*/current_now
```

## Troubleshooting

### High power consumption
1. Check which devices are not using runtime PM:
   ```bash
   find /sys/bus/pci/devices/*/power/control -exec sh -c 'echo "{}: $(cat {})"' \; | grep -v auto
   ```

2. Check CPU frequency:
   ```bash
   cat /proc/cpuinfo | grep MHz
   ```

3. Install powertop for detailed analysis:
   ```bash
   sudo apt install powertop
   sudo powertop
   ```

### Device issues after enabling power saving
Some devices don't work well with runtime PM. To keep a specific device powered:
```bash
echo on | sudo tee /sys/bus/pci/devices/<device>/power/control
```

## Notes

- Screen brightness has the largest impact on battery life (control manually)
- Critical system devices (host bridge, RAM controller) cannot use runtime PM
- The hibernate fix service ensures stable resume from hibernation
- AirCard stays powered due to instability with autosuspend
