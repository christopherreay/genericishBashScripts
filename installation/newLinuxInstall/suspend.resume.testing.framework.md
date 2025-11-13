# Suspend/Resume Testing Framework
## Acer Nitro ANV15-51 - Linux Kernel 6.12.38+deb12-amd64

### Current Problem
- 40% suspend/resume failure rate
- ACPI BIOS errors during resume: `\_SB.PC00.RP08.LREN`, `AE_NOT_FOUND`
- USB controller errors: `xhci_hcd 0000:00:0d.0: xHC error in resume`
- SPD5118 memory sensor errors: `Failed to write b = 0: -6`

### Testing Strategy Tree

```
Current Working State (Baseline - 40% failure rate)
├── Test Branch 1: Memory/Sleep Mode
│   ├── mem_sleep_default=shallow     [STATUS: NOT TESTED]
│   ├── mem_sleep_default=deep        [STATUS: NOT TESTED]
│   └── mem_sleep_default=s2idle      [STATUS: NOT TESTED]
├── Test Branch 2: ACPI Workarounds
│   ├── acpi_sleep=nonvs              [STATUS: NOT TESTED]
│   ├── acpi_osi=Linux                [STATUS: NOT TESTED]
│   └── acpi_osi="Windows 2020"      [STATUS: NOT TESTED]
├── Test Branch 3: Hardware Timing
│   ├── cpu_init_udelay=50000         [STATUS: GRUB ENTRY CREATED]
│   ├── usbcore.old_scheme_first=1    [STATUS: NOT TESTED]
│   └── pcie_aspm=off                 [STATUS: NOT TESTED]
├── Test Branch 4: Driver Blacklists
│   ├── blacklist spd5118             [STATUS: NOT TESTED]
│   ├── blacklist intel_pmc_core      [STATUS: NOT TESTED]
│   └── USB autosuspend fixes         [STATUS: PARTIAL - applied]
└── Test Branch 5: Combined Solutions
    ├── Best individual fixes combined [STATUS: NOT TESTED]
    └── Fallback configurations       [STATUS: NOT TESTED]
```

### Boot Safety Mechanisms
- Multiple GRUB entries for testing
- Original kernel parameters preserved
- Easy rollback to working state
- Automatic fallback on boot failure

### Current Configuration
- Lid close: suspend
- 15 minutes idle: hibernate
- Suspend key: hibernate
- USB autosuspend disabled (applied)

### Hardware Details
- Motherboard: Acer Nitro ANV15-51
- CPU: 13th Gen Intel i7-13620H
- GPU: Intel UHD + NVIDIA RTX 4060 Max-Q
- RAM: DDR5 (with problematic SPD5118 sensor)
- BIOS: INSYDE Corp. V1.09 (01/08/2024)

## Important Finding: Invalid Parameter ❌
**RESOLVED**: The `resume_delay=5000` parameter **does not exist** in the Linux kernel (verified via context7 documentation lookup). This explains why it had no effect during testing.

**Valid timing parameters:**
- `cpu_init_udelay=N` - Controls CPU initialization delay during resume (microseconds)
- `mem_sleep_default=` - Controls suspend mode (s2idle, shallow, deep)
- `acpi_sleep=` - ACPI suspend workarounds

## Available Test Entries (Updated)
1. **Test: shallow sleep** - `mem_sleep_default=shallow`
2. **Test: ACPI nonvs** - `acpi_sleep=nonvs`
3. **Test: deep sleep + CPU init delay** - `mem_sleep_default=deep cpu_init_udelay=50000`
4. **Test: s2idle suspend mode** - `mem_sleep_default=s2idle`
5. **Debug: Deep sleep with maximum logging** - `mem_sleep_default=deep pm_debug_messages no_console_suspend initcall_debug loglevel=8 pm_trace=1`

## Debug Data Collection Procedure

### Step 1: Boot into Debug Mode
Boot using "Debug: Deep sleep with maximum logging" GRUB entry

### Step 2: Set Up Debug Environment
```bash
# Run the debug helper setup
./Scripts/installation/newLinuxInstall/suspend.debug.helper.sh setup
```

### Step 3: Systematic Testing Phases
Test individual components to isolate the problem:

```bash
# Test device suspend/resume only
./suspend.debug.helper.sh test-devices
systemctl suspend

# Test platform (ACPI) suspend/resume
./suspend.debug.helper.sh test-platform
systemctl suspend

# Test processor suspend/resume
./suspend.debug.helper.sh test-processors
systemctl suspend

# Full suspend/resume with logging
./suspend.debug.helper.sh test-none
systemctl suspend
```

### Step 4: Data Analysis
- Check suspend statistics: `./suspend.debug.helper.sh stats`
- Check PM trace matches: `./suspend.debug.helper.sh check-match`
- Analyze logs in `Scripts/installation/newLinuxInstall/suspend.logs/`

### Next Steps
1. ✅ Set up GRUB testing entries (COMPLETE)
2. ✅ Create debug data collection framework (COMPLETE)
3. 🔄 Test each branch systematically with debug data
4. Analyze timing data to identify race conditions
5. Implement targeted subsystem delays based on data
6. Create final optimized configuration