# QEMU with virt-manager, SPICE, and VirtioFS Installation

## Overview

This documentation covers the installation and setup of QEMU virtualization with virt-manager GUI, SPICE display protocol, and VirtioFS file sharing support on Debian/Ubuntu systems.

## Installation Script

**Location**: `Scripts/installation/newLinuxInstall/qemu.install.withVirtManagerSpiceVirtiofs.sh`

**What it installs**:
- QEMU/KVM virtualization platform
- virt-manager graphical management interface
- SPICE display and input protocol
- VirtioFS file sharing capabilities
- Required dependencies and user permissions

## Components Explained

### QEMU/KVM
- **qemu-kvm**: Main KVM virtualization package
- **qemu-utils**: QEMU utilities (qemu-img, etc.)
- **qemu-system-x86**: x86/x64 system emulation
- **cpu-checker**: Tool to verify KVM support

### libvirt
- **libvirt-daemon-system**: Virtualization management daemon
- **libvirt-clients**: Command-line tools (virsh, etc.)
- **bridge-utils**: Network bridging utilities

### virt-manager
- **virt-manager**: Graphical VM management interface
- **virtinst**: VM installation tools
- **virt-viewer**: VM console viewer

### SPICE
- **spice-client-gtk**: SPICE display client
- **spice-vdagent**: Guest agent for clipboard/resolution
- **qemu-guest-agent**: Enhanced guest integration

### VirtioFS
- Built into modern QEMU versions
- Provides high-performance file sharing between host and guest
- Uses virtio-9p-pci device type

## Post-Installation Steps

1. **Log out and back in** - Required for group permissions to take effect
2. **Start virt-manager** - Run `virt-manager` command
3. **Verify installation** - Use provided verification commands

## Usage Examples

### Creating a VM with VirtioFS
1. Open virt-manager
2. Create new VM
3. In VM configuration, add hardware → Filesystem
4. Set:
   - Driver: `virtio-9p`
   - Source path: `/path/on/host`
   - Target path: `mount_tag_name`
5. In guest OS, mount with: `mount -t 9p -o trans=virtio mount_tag_name /mnt/shared`

### SPICE Configuration
- SPICE is automatically configured for new VMs
- Provides clipboard sharing, dynamic resolution
- Better performance than VNC for local VMs

## Verification Commands

```bash
# Check KVM support
kvm-ok

# List VMs
virsh list --all

# Check user groups (should include libvirt, libvirt-qemu, kvm)
groups $(whoami)

# Test QEMU installation
qemu-system-x86_64 --version

# Check VirtioFS support
qemu-system-x86_64 -device help | grep virtio-9p
```

## Troubleshooting

### KVM Not Available
- Check if virtualization is enabled in BIOS/UEFI
- Verify CPU supports virtualization (Intel VT-x or AMD-V)
- Run `kvm-ok` for detailed diagnostics

### Permission Issues
- Ensure user is in required groups: `libvirt`, `libvirt-qemu`, `kvm`
- Log out and back in after running install script
- Check with: `groups $(whoami)`

### VirtioFS Not Working
- Ensure guest OS has 9p filesystem support
- Check mount command syntax
- Verify VM has virtio-9p-pci device added

### SPICE Display Issues
- Install spice-vdagent in guest OS
- Check VM has SPICE display (not VNC)
- Ensure spice-gtk package installed on host

## Security Notes

- VMs run with restricted permissions
- libvirt provides isolation between VMs
- VirtioFS shares are read-only by default (can be configured)
- SPICE connections are local-only by default