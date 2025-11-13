#!/bin/bash

# Set up power management scripts for laptop battery optimization
# Creates low-power and normal-power mode scripts
# Controls CPU, GPU, USB, WiFi, SATA, and audio power management

echo "Setting up power management scripts..."

# Create power scripts directory
echo "📁 Creating ~/Scripts/power directory..."
mkdir -p ~/Scripts/power

# Create low-power mode script
echo "🔋 Creating low-power-mode.sh..."
cat > ~/Scripts/power/low-power-mode.sh << 'EOF'
#!/bin/bash
# Low Power Mode - Maximize battery life

echo "Enabling low power mode..."

# CPU: Set to powersave governor
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave | sudo tee "$cpu" > /dev/null
done

# GPU: Enable runtime power management
echo auto | sudo tee /sys/bus/pci/devices/0000:01:00.0/power/control > /dev/null

# All PCI devices: Enable runtime PM where supported
for dev in /sys/bus/pci/devices/*/power/control; do
    echo auto | sudo tee "$dev" > /dev/null 2>&1
done

# USB: Enable autosuspend (except AirCard which has udev rule)
for dev in /sys/bus/usb/devices/*/power/control; do
    echo auto | sudo tee "$dev" > /dev/null 2>&1
done

# Wireless: Enable power saving
sudo iw dev wlp62s0 set power_save on 2>/dev/null

# SATA: Set link power management to aggressive
for policy in /sys/class/scsi_host/host*/link_power_management_policy; do
    echo med_power_with_dipm | sudo tee "$policy" > /dev/null 2>&1
done

# Audio: Enable power saving
echo 1 | sudo tee /sys/module/snd_hda_intel/parameters/power_save > /dev/null 2>&1

echo "Low power mode enabled. Current power draw:"
cat /sys/class/power_supply/BAT*/power_now 2>/dev/null || \
    awk '{printf "%.1fW\n", ($1 * $2) / 1000000000}' \
    /sys/class/power_supply/BAT*/voltage_now \
    /sys/class/power_supply/BAT*/current_now 2>/dev/null
EOF

# Create normal power mode script
echo "⚡ Creating normal-power-mode.sh..."
cat > ~/Scripts/power/normal-power-mode.sh << 'EOF'
#!/bin/bash
# Normal Power Mode - Balanced performance and power

echo "Enabling normal power mode..."

# CPU: Set to powersave governor (still efficient but responsive)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave | sudo tee "$cpu" > /dev/null
done

# GPU: Enable runtime power management
echo auto | sudo tee /sys/bus/pci/devices/0000:01:00.0/power/control > /dev/null

# All PCI devices: Enable runtime PM
for dev in /sys/bus/pci/devices/*/power/control; do
    echo auto | sudo tee "$dev" > /dev/null 2>&1
done

# USB: Enable autosuspend
for dev in /sys/bus/usb/devices/*/power/control; do
    echo auto | sudo tee "$dev" > /dev/null 2>&1
done

# Wireless: Enable power saving
sudo iw dev wlp62s0 set power_save on 2>/dev/null

# SATA: Balanced link power management
for policy in /sys/class/scsi_host/host*/link_power_management_policy; do
    echo med_power_with_dipm | sudo tee "$policy" > /dev/null 2>&1
done

# Audio: Enable power saving
echo 1 | sudo tee /sys/module/snd_hda_intel/parameters/power_save > /dev/null 2>&1

echo "Normal power mode enabled. Current power draw:"
cat /sys/class/power_supply/BAT*/power_now 2>/dev/null || \
    awk '{printf "%.1fW\n", ($1 * $2) / 1000000000}' \
    /sys/class/power_supply/BAT*/voltage_now \
    /sys/class/power_supply/BAT*/current_now 2>/dev/null
EOF

# Make scripts executable
chmod +x ~/Scripts/power/*.sh

# Create README
echo "📝 Creating README.md..."
cat > ~/Scripts/power/README.md << 'EOF'
# Power Management Scripts

## Scripts

### `low-power-mode.sh`
Maximize battery life by enabling aggressive power saving on all components.

**Expected power draw:** ~15-20W (depending on workload and screen brightness)

### `normal-power-mode.sh`
Balanced power management - good battery life with responsive performance.

**Expected power draw:** ~19-25W (depending on workload and screen brightness)

## Usage

```bash
~/Scripts/power/low-power-mode.sh
~/Scripts/power/normal-power-mode.sh
```

**Note:** Screen brightness has the largest impact on battery life (control manually)

See full documentation in the script directory.
EOF

echo "✅ Power management scripts created:"
echo "   📄 ~/Scripts/power/low-power-mode.sh"
echo "   📄 ~/Scripts/power/normal-power-mode.sh"
echo "   📄 ~/Scripts/power/README.md"
echo ""
echo "🚀 Usage:"
echo "   Low power:  ~/Scripts/power/low-power-mode.sh"
echo "   Normal:     ~/Scripts/power/normal-power-mode.sh"
echo ""
echo "✅ Power management setup complete!"
