# Scripts Directory Reorganization Report

## Current State Analysis

### Issues Identified
1. **Poor naming conventions**: Many files lack extensions (e.g., `backlight`, `convertMovieToGif`)
2. **Inconsistent naming patterns**: Mix of camelCase, kebab-case, dots, and underscores
3. **Flat structure**: ~1022 executable scripts with minimal organization
4. **Cryptic names**: Files like `4913`, `5036`, `getFromGermany`
5. **Duplicated categories**: Multiple directories for similar functions
6. **Mixed purposes**: Root directory contains everything from hardware controls to media processing

### Current Categories Found
- **Hardware control**: brightness, bluetooth, monitors, touchpad
- **Media processing**: ffmpeg scripts, video conversion
- **Network/VPN**: nordvpn, openpyn scripts
- **SSH/Remote access**: numerous digitalOcean connection scripts  
- **Browser management**: profile backups, cache clearing
- **System maintenance**: power management, runtime tasks
- **Installation scripts**: various software installers

## Recommended Reorganization

### 1. Directory Structure
```
Scripts/
├── audio/              # Audio processing and bluetooth
├── backup/             # Backup and sync scripts  
├── browser/            # Browser-related scripts
├── hardware/           # Hardware control (existing, needs cleanup)
├── installation/       # Software installation (existing, needs cleanup)
├── media/              # Video/image processing
├── communications/     # SSH, remote connections (existing, keep as-is)
├── network/            # VPN, connectivity (non-SSH)
├── power/              # Power management, suspend scripts
├── system/             # System maintenance and utilities
├── development/        # Development tools and git scripts
└── deprecated/         # Old/unused scripts (existing)
```

### 2. Naming Convention Standards: Command-First with Dot Hierarchy
- **Structure**: `commandName.category.specificAction`
- **CamelCase within segments**: Each dot-separated segment uses camelCase
- **Dots for categorization**: Separate command from functional area and specific action
- **Extensions**: Use `.sh` for bash scripts, appropriate extensions for others (`.js`, `.py`, etc.)

**Examples of the pattern:**
- `ffmpeg.videoConversion.movieToGif.sh`
- `bluetoothctl.audioDevices.connectHeadphones.sh` 
- `systemctl.powerManagement.suspendToRam.sh`
- `git.repositoryMaintenance.pushAllBranches.sh`
- `node.dataProcessing.parseLogFiles.js`

**Benefits for heterogeneous systems**:
- Command dependency immediately visible
- Hierarchical organization through dots
- Natural grouping and discoverability
- Consistent `.sh` extensions enable easy filtering and monitoring

### 3. Specific Recommendations

#### Root Directory Cleanup
**Rename with command-first dot hierarchy:**
- `4913`, `5036` → Identify underlying commands and rename appropriately
- `backlight` → `xrandr.displayControl.backlight.sh` or `brightnessctl.display.setBrightness.sh`
- `convertMovieToGif` → `ffmpeg.videoConversion.movieToGif.sh`
- `browser.cache.deleteAll` → `find.browserMaintenance.deleteAllCaches.sh` or `rm.browserData.clearCaches.sh`
- `suspendToMemory` → `systemctl.powerManagement.suspendToRam.sh`
- `plantronicsProfileResetLoop` → `bluetoothctl.audioDevices.plantronicsResetLoop.sh`
- `ffmpeg_turnAudioIntoVideoForYoutube` → `ffmpeg.audioConversion.audioToVideoYoutube.sh`
- `yt-dlt.bestAudioNoVideo` → `yt-dlp.audioDownload.bestAudioOnly.sh`

#### Communications Directory
The `communications/` directory is well-organized and should remain as-is. No changes needed for SSH connection scripts.

#### Hardware Directory
Apply command-first dot naming:
- `brightness-up` → `brightnessctl.display.brightnessUp.sh` or `xrandr.brightness.increase.sh`
- `brightness-down` → `brightnessctl.display.brightnessDown.sh` or `xrandr.brightness.decrease.sh`
- `touchPadDisable` → `xinput.touchpad.disable.sh`
- `touchPadEnable` → `xinput.touchpad.enable.sh`
- `bluetoothAudioDevices.add` → `bluetoothctl.audioDevices.addDevice.sh`

#### Media Processing
Create `media/` directory for:
- All ffmpeg scripts
- Video/image conversion tools
- YouTube download scripts

### 4. Implementation Strategy

#### Phase 1: Create new structure
```bash
mkdir -p audio backup browser media network power system development
```

#### Phase 2: Move and rename files systematically
- Start with obvious categories (hardware already partially done)
- Use git mv to preserve history
- Update any scripts that reference moved files

#### Phase 3: Standardize naming
- Add appropriate extensions
- Rename cryptic files with descriptive names
- Update internal documentation/comments

### 5. Benefits of Command-First Reorganization
- **Dependency transparency**: Immediately know what tools are required
- **System compatibility**: Quick identification of scripts that won't work on current system
- **Natural grouping**: Related commands cluster together (`git-*`, `docker-*`, etc.)
- **Accurate expectations**: Command name prevents misleading assumptions about functionality
- **Maintainability**: When commands change, affected scripts are obvious
- **Heterogeneous system support**: Works consistently across different environments

### 6. Scripts Requiring Special Attention
- Files without clear purpose: `4913`, `5036`, `getFromGermany`
- Potential duplicates in different directories
- Scripts that may reference absolute paths to other scripts

## Next Steps
1. Audit existing scripts to identify underlying commands
2. Create backup of current structure  
3. Implement command-first renaming systematically
4. Update any dependent scripts that reference renamed files
5. Create style guide emphasizing command-first naming for future additions

## Command-First Dot Hierarchy Style Guide
```
commandName.category.specificAction.extension

Examples:
- ffmpeg.videoConversion.convertToWebmHighQuality.sh
- git.repositoryMaintenance.pushAllBranches.sh  
- systemctl.networkServices.restartNetworking.sh
- bluetoothctl.audioDevices.connectHeadphones.sh
- docker.maintenance.cleanupUnusedImages.sh
- node.dataProcessing.parseApiResponse.js

Benefits of consistent extensions:
- Easy filtering: inotifywait can monitor .sh, .js, .py files
- Clear script identification in mixed directories
- Enables precise execution logging and monitoring
```

### Output Directory Naming Conventions

Scripts that generate output should create directories that match the script name pattern:

#### Script-Specific Output Directories
- **Pattern**: `command.category.action.{logs|data|tmp|config}/`
- **Location**: Same directory as the script
- **Structure**: Each script gets its own output directory namespace

#### Directory Types:
- **`.logs/`** - Log files, execution history, debug output
- **`.data/`** - Primary output files, processed data, downloads  
- **`.tmp/`** - Temporary working files, intermediate processing
- **`.config/`** - Script-specific configuration, cache files

#### Examples:
```
ffmpeg.videoConversion.movieToGif.sh
ffmpeg.videoConversion.movieToGif.logs/
├── 2024-08-28_conversion.log
├── error.log
└── processing_stats.txt

ffmpeg.videoConversion.movieToGif.data/
├── output_movie.gif
└── thumbnails/

youtube.download.audioPlaylist.sh  
youtube.download.audioPlaylist.data/
├── 2024-08-28_playlist/
│   ├── track01.m4a
│   └── track02.m4a
└── metadata.json

youtube.download.audioPlaylist.logs/
└── download_2024-08-28.log
```

#### Shared Output (Exception Cases):
Only use common directories when multiple scripts need shared access:
- **`/tmp/scripts.shared/`** - System-wide temporary files
- **`./shared.logs/`** - When multiple scripts contribute to same log
- **`./shared.config/`** - Common configuration used by multiple scripts

#### Benefits:
- **Isolated output**: Each script's files are completely contained
- **Easy cleanup**: Delete entire output directory to clean up
- **Clear ownership**: Obvious which script created which files  
- **Parallel execution**: No file conflicts between different scripts
- **Predictable locations**: Output always matches script name pattern