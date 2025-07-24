i#!/usr/bin/env python3
from i3ipc import Connection

i3 = Connection()

# === CONFIGURABLE COLORS ===
highlight_color = '#ff8800'
normal_color = '#222222'

def reset_borders():
    for win in i3.get_tree().leaves():
        win.command('border pixel 1')
        win.command(f'border_color {normal_color} {normal_color} {normal_color}')

def highlight_parents(container):
    parent = container.parent
    while parent:
        if parent.type == 'con':  # Only style containers, not workspaces/outputs
            parent.command('border pixel 3')
            parent.command(f'border_color {highlight_color} {highlight_color} {highlight_color}')
        parent = parent.parent

def on_focus(i3conn, event):
    reset_borders()
    highlight_parents(event.container)

# Initial
reset_borders()
highlight_parents(i3.get_tree().find_focused())

# Subscribe
i3.on('window::focus', on_focus)
i3.main()
