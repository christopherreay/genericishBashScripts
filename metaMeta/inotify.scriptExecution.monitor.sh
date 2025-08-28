#!/bin/bash

# Script execution monitor using inotify
# Monitors .sh file executions in Scripts directory and subdirectories

SCRIPTS_DIR="/contextData/christopher/Scripts"
LOG_FILE="$SCRIPTS_DIR/.execution_log"
PID_FILE="$SCRIPTS_DIR/.monitor.pid"

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Function to log execution
log_execution() {
    local file_path="$1"
    local event_type="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local user=$(whoami)
    local relative_path=${file_path#$SCRIPTS_DIR/}
    
    echo "[$timestamp] [$user] [$event_type] $relative_path" >> "$LOG_FILE"
}

# Function to stop monitor
stop_monitor() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill "$pid" 2>/dev/null; then
            echo "Script monitor stopped (PID: $pid)"
        else
            echo "Process $pid not found (may have already exited)"
        fi
        rm -f "$PID_FILE"
    else
        echo "No monitor running"
    fi
}

# Function to start monitor
start_monitor() {
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "Monitor already running (PID: $(cat $PID_FILE))"
        return 1
    fi
    
    # Remove stale PID file if process is dead
    [ -f "$PID_FILE" ] && rm -f "$PID_FILE"
    
    echo "Starting script execution monitor..."
    echo "Monitoring: $SCRIPTS_DIR"
    echo "Log file: $LOG_FILE"
    echo "Filtering: *.sh, *.js, *.py files"
    
    # Monitor .sh, .js, and .py files for access (execution) events
    # Using --include to only watch script files
    inotifywait -m -r -e access "$SCRIPTS_DIR" \
        --include='\.(sh|js|py)$' \
        --exclude='\.git|node_modules|\.execution_log|\.monitor\.pid' \
        --format '%w%f %e %T' --timefmt '%Y-%m-%d %H:%M:%S' | while read file event timestamp; do
        
        # Log script executions (check if executable or if it's a script file)
        if [ -f "$file" ] && { [ -x "$file" ] || [[ "$file" =~ \.(js|py)$ ]]; }; then
            log_execution "$file" "EXECUTED"
            # Also log to stdout for real-time monitoring
            echo "EXECUTED: ${file#$SCRIPTS_DIR/} at $timestamp"
        fi
    done &
    
    echo $! > "$PID_FILE"
    echo "Monitor started with PID: $(cat $PID_FILE)"
}

# Function to show log
show_log() {
    if [ -f "$LOG_FILE" ]; then
        if [ "$1" = "follow" ] || [ "$1" = "-f" ]; then
            tail -f "$LOG_FILE"
        else
            tail -n ${1:-20} "$LOG_FILE"
        fi
    else
        echo "No execution log found"
    fi
}

# Function to show status
show_status() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Monitor running (PID: $pid)"
            echo "Log entries: $(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)"
        else
            echo "Monitor not running (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        echo "Monitor not running"
    fi
}

# Function to list all running inotify monitors
list_monitors() {
    echo "All running inotify processes:"
    ps aux | grep inotifywait | grep -v grep || echo "No inotify monitors running"
}

# Function to clear log
clear_log() {
    if [ -f "$LOG_FILE" ]; then
        > "$LOG_FILE"
        echo "Execution log cleared"
    else
        echo "No log file to clear"
    fi
}

# Main command handling
case "${1:-start}" in
    start)
        start_monitor
        ;;
    stop)
        stop_monitor
        ;;
    restart)
        stop_monitor
        sleep 1
        start_monitor
        ;;
    status)
        show_status
        ;;
    log)
        show_log "$2"
        ;;
    clear)
        clear_log
        ;;
    list)
        list_monitors
        ;;
    help|--help|-h)
        echo "Usage: $0 {start|stop|restart|status|log [lines|follow]|clear|list}"
        echo ""
        echo "Commands:"
        echo "  start         - Start monitoring .sh, .js, .py script executions"
        echo "  stop          - Stop monitoring"
        echo "  restart       - Restart monitoring" 
        echo "  status        - Show monitor status and log count"
        echo "  log [n]       - Show last n lines of execution log (default: 20)"
        echo "  log follow    - Follow execution log in real-time"
        echo "  clear         - Clear the execution log"
        echo "  list          - List all running inotify monitors"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac