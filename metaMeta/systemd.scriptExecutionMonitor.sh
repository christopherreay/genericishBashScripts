#!/bin/bash

# Script execution monitor for systemd
# Monitors .sh, .js, .py file executions and logs to .execution_log

SCRIPTS_DIR="${SCRIPTS_DIR:-/contextData/christopher/Scripts}"
LOG_DIR="$SCRIPTS_DIR/metaMeta/systemd.scriptExecutionMonitor.logs"
LOG_FILE="${LOG_FILE:-$LOG_DIR/execution.log}"

# Create log directory and file if they don't exist
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# Function to log execution
log_execution() {
    local file_path="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local user=$(whoami)
    local relative_path=${file_path#$SCRIPTS_DIR/}
    
    echo "[$timestamp] [$user] [EXECUTED] $relative_path" >> "$LOG_FILE"
}

# Trap signals for graceful shutdown
cleanup() {
    echo "Script execution monitor shutting down..."
    exit 0
}
trap cleanup SIGTERM SIGINT

# Systemd service definition (embedded)
generate_service() {
    cat << 'EOF'
[Unit]
Description=Script Execution Monitor
After=network.target

[Service]
Type=simple
User=christopher
Group=christopher
WorkingDirectory=/contextData/christopher/Scripts
ExecStart=/contextData/christopher/Scripts/metaMeta/systemd.scriptExecutionMonitor.sh
Restart=always
RestartSec=5
Environment=SCRIPTS_DIR=/contextData/christopher/Scripts
Environment=LOG_FILE=/contextData/christopher/Scripts/metaMeta/systemd.scriptExecutionMonitor.logs/execution.log
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths=/contextData/christopher/Scripts
StandardOutput=journal
StandardError=journal
SyslogIdentifier=script-monitor

[Install]
WantedBy=multi-user.target
EOF
}

# Command handling
case "${1:-monitor}" in
    monitor)
        # Main monitoring mode (default - used by systemd)
        echo "Starting script execution monitor..."
        echo "Monitoring: $SCRIPTS_DIR"
        echo "Log file: $LOG_FILE"
        
        inotifywait -m -r -e access "$SCRIPTS_DIR" \
            --include='\.(sh|js|py)$' \
            --format '%w%f' | while read file; do
            
            if [ -f "$file" ] && { [ -x "$file" ] || [[ "$file" =~ \.(js|py)$ ]]; }; then
                log_execution "$file"
            fi
        done
        ;;
        
    install)
        # Install systemd service
        echo "Installing script execution monitor service..."
        generate_service | sudo tee /etc/systemd/system/script-execution-monitor.service > /dev/null
        sudo systemctl daemon-reload
        sudo systemctl enable script-execution-monitor
        echo "Service installed. Use: sudo systemctl start script-execution-monitor"
        ;;
        
    uninstall)
        # Remove systemd service
        sudo systemctl stop script-execution-monitor 2>/dev/null
        sudo systemctl disable script-execution-monitor 2>/dev/null
        sudo rm -f /etc/systemd/system/script-execution-monitor.service
        sudo systemctl daemon-reload
        echo "Service uninstalled."
        ;;
        
    help|--help|-h)
        echo "Usage: $0 {monitor|install|uninstall}"
        echo ""
        echo "Commands:"
        echo "  monitor     - Run monitoring (default, used by systemd)"
        echo "  install     - Install systemd service"
        echo "  uninstall   - Remove systemd service"
        echo ""
        echo "Service control:"
        echo "  sudo systemctl start script-execution-monitor"
        echo "  sudo systemctl stop script-execution-monitor" 
        echo "  sudo systemctl status script-execution-monitor"
        echo ""
        echo "View logs:"
        echo "  tail -f /contextData/christopher/Scripts/metaMeta/systemd.scriptExecutionMonitor.logs/execution.log"
        echo "  journalctl -u script-execution-monitor"
        ;;
        
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac