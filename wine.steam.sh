#!/bin/bash

# Wine Steam launcher script
# Uses the existing wine-steam WINEPREFIX

export WINEPREFIX="/torrents/christopher/games/wine-steam"

# Launch wine with the specified prefix
wine "$@"