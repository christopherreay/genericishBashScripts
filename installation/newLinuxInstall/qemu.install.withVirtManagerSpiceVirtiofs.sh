#!/bin/bash

# Install QEMU with virt-manager, SPICE, and VirtioFS support
# Complete virtualization setup for Debian/Ubuntu systems

echo "Installing QEMU with virt-manager, SPICE, and VirtioFS support..."

# Update package list
sudo apt update

# Install base QEMU and KVM packages
echo "Installing base QEMU and KVM packages..."
sudo apt install -y \
    qemu-kvm \
    qemu-utils \
    qemu-system-x86 \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    cpu-checker

# Install virt-manager GUI
echo "Installing virt-manager GUI..."
sudo apt install -y \
    virt-manager \
    virtinst \
    virt-viewer

# Install SPICE support
echo "Installing SPICE support packages..."
sudo apt install -y \
    spice-client-gtk \
    spice-vdagent \
    qemu-guest-agent

# VirtioFS support (included in modern QEMU)
echo "Verifying VirtioFS support..."
if qemu-system-x86_64 -device help | grep -q virtio-9p; then
    echo "VirtioFS support available"
else
    echo "Warning: VirtioFS support may be limited"
fi

# Add user to libvirt groups
echo "Adding user $(whoami) to libvirt groups..."
sudo usermod -a -G libvirt $(whoami)
sudo usermod -a -G libvirt-qemu $(whoami)
sudo usermod -a -G kvm $(whoami)

# Start and enable libvirt services
echo "Starting libvirt services..."
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

# Check KVM support
echo "Checking KVM support..."
kvm-ok

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Log out and back in for group permissions to take effect"
echo "2. Run 'virt-manager' to start the GUI"
echo "3. For VirtioFS, use device type 'virtio-9p-pci' in VM configuration"
echo ""
echo "Verification commands:"
echo "  virsh list --all"
echo "  groups \$(whoami)  # Should show libvirt, libvirt-qemu, kvm"