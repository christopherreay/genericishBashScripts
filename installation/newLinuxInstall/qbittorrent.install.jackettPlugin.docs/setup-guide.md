# qBittorrent Jackett Plugin Installation Guide

## Overview

This script installs and configures the Jackett plugin for qBittorrent, enabling torrent searches across multiple indexers through a unified interface.

## What Gets Installed

### Core Components
- **.NET 8 Runtime** - Required dependency for Jackett
- **Jackett** - Indexer proxy service
- **qBittorrent** - BitTorrent client (if not already installed)
- **Jackett Plugin** - qBittorrent search plugin

### System Integration
- **Systemd service** for Jackett auto-startup
- **Configuration files** in proper locations
- **User permissions** setup

## Installation Process

1. **Dependencies**: Installs Microsoft .NET 8 runtime
2. **Jackett**: Downloads latest release and sets up in `/opt/Jackett`
3. **Service**: Creates systemd service for auto-start
4. **Plugin**: Downloads Jackett plugin for qBittorrent
5. **Configuration**: Creates sample config file

## Post-Installation Setup

### 1. Configure Jackett
1. Open web interface: `http://localhost:9117`
2. Copy API key from dashboard
3. Add indexers (trackers) you want to search

### 2. Update Plugin Configuration
Edit: `~/.local/share/qBittorrent/nova3/engines/jackett.json`
```json
{
    "api_key": "paste_your_api_key_here",
    "url": "http://127.0.0.1:9117",
    "tracker_first": false,
    "thread_count": 20
}
```

### 3. Enable in qBittorrent
1. Open qBittorrent
2. Go to Search tab
3. Click "Search plugins..."
4. Enable Jackett plugin
5. Restart qBittorrent

## Configuration Options

### jackett.json Parameters
- **api_key**: Your Jackett API key (required)
- **url**: Jackett service URL (default: localhost:9117)
- **tracker_first**: Prepend tracker name to search results
- **thread_count**: Max concurrent search requests (adjust based on system)

### Remote Access
To access Jackett remotely:
1. Change URL in config: `http://your-server-ip:9117`
2. Configure firewall to allow port 9117
3. Update Jackett binding address if needed

## Service Management

```bash
# Start Jackett
sudo systemctl start jackett

# Stop Jackett  
sudo systemctl stop jackett

# Check status
sudo systemctl status jackett

# View logs
journalctl -u jackett -f
```

## File Locations

- **Jackett installation**: `/opt/Jackett/`
- **Systemd service**: `/etc/systemd/system/jackett.service`
- **Plugin file**: `~/.local/share/qBittorrent/nova3/engines/jackett.py`
- **Configuration**: `~/.local/share/qBittorrent/nova3/engines/jackett.json`
- **Jackett config**: `/opt/Jackett/ServerConfig.json`

## Troubleshooting

### Plugin Not Appearing
- Restart qBittorrent completely
- Check plugin file permissions
- Verify configuration file syntax

### Jackett Not Starting
- Check .NET runtime installation: `dotnet --version`
- Review service logs: `journalctl -u jackett`
- Verify port 9117 is not in use: `netstat -tlnp | grep 9117`

### Search Not Working
- Verify API key is correct
- Check Jackett web interface is accessible
- Ensure indexers are configured in Jackett
- Test connectivity: `curl http://localhost:9117/api/v2.0/indexers/all/results/torznab/api?apikey=YOUR_KEY&t=search&q=test`

### .NET Installation Issues
- Clear package cache: `sudo apt clean`
- Remove and reinstall Microsoft package repository
- Check Debian version compatibility

## Security Considerations

- Jackett runs as user service (not root)
- API key provides access control
- Default binding is localhost only
- Consider VPN for remote access to indexers

## Performance Tuning

- Adjust `thread_count` based on system resources
- Configure indexer priorities in Jackett
- Set appropriate timeout values for slow indexers
- Monitor system resources during heavy search loads

## Integration with Other Tools

- **Sonarr/Radarr**: Can use same Jackett instance
- **Prowlarr**: Alternative to Jackett (not compatible)
- **Flaresolverr**: For CloudFlare-protected indexers

## Updating

### Jackett Updates
- Stop service: `sudo systemctl stop jackett`
- Download new release to `/opt/Jackett`
- Start service: `sudo systemctl start jackett`

### Plugin Updates
- Re-run plugin download section of script
- Or manually update from GitHub releases