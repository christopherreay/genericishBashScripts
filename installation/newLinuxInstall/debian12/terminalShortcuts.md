# Fix Terminal Shortcuts on Debian 12 GNOME

## Problem
When using GNOME's application search (Super key + "terminal"), only one terminal window is created. If a terminal is already open, the search does nothing instead of creating a new terminal window.

This happens due to GNOME's application grouping behavior that focuses existing windows instead of creating new instances.

## Solution: Custom Keyboard Shortcuts

Set up keyboard shortcuts that always create new terminal windows, bypassing GNOME's application grouping.

### Setup Custom Terminal Shortcuts

**1. Create Custom Keybinding Slots:**
```bash
# Create two custom keybinding slots
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
```

**2. Configure Ctrl+Alt+T Shortcut:**
```bash
# Set up Ctrl+Alt+T for new terminal
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "New Terminal"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "gnome-terminal"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Control><Alt>t"
```

**3. Configure Super+Enter Shortcut:**
```bash
# Set up Super+Enter for forced new terminal
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Force New Terminal"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "bash -c 'gnome-terminal & disown'"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Super>Return"
```

## Usage

After setup, you have multiple ways to open new terminals:

- **`Ctrl + Alt + T`** → Opens new terminal window
- **`Super + Enter`** → Forces new terminal instance  
- **Right-click terminal icon** → Select "New Window" from context menu
- **Use launcher search** → Still works for first terminal, then use shortcuts for additional ones

## Verification

Test the shortcuts:
```bash
# Check if keybindings were created correctly
gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings

# Check individual keybinding settings
gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding

gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding
```

Both shortcuts should return the configured key combinations and always create new terminal windows.

## Alternative Solutions

**1. Use Terminal Multiplexer:**
```bash
# Install tmux for terminal session management
sudo -A apt install tmux -y

# Use tmux within one terminal for multiple sessions
tmux new-session -d -s main
```

**2. Pin Terminal to Dock:**
- Right-click terminal in Activities
- Select "Add to Favorites"
- Right-click dock icon → "New Window"

**3. Use Different Terminal Emulator:**
```bash
# Install alternative terminal that doesn't group windows
sudo -A apt install tilix -y
# Then create shortcuts using "tilix" instead of "gnome-terminal"
```

## Troubleshooting

**If shortcuts don't work:**
```bash
# Test command manually
gnome-terminal

# Check for keybinding conflicts in Settings > Keyboard > Shortcuts
# Look for conflicting assignments to Ctrl+Alt+T or Super+Enter

# Remove and recreate keybindings if needed
gsettings reset org.gnome.settings-daemon.plugins.media-keys custom-keybindings
```

**To remove custom shortcuts:**
```bash
# Reset to default (removes all custom keybindings)
gsettings reset org.gnome.settings-daemon.plugins.media-keys custom-keybindings
```

This solution provides reliable access to multiple terminal instances without being limited by GNOME's application grouping behavior.