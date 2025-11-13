#!/bin/bash

# Suspend/Resume Debug Helper Script
# This script sets up comprehensive debug logging for suspend/resume testing

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Suspend/Resume Debug Helper ===${NC}"

# Function to enable PM tracing
enable_pm_trace() {
    echo -e "${YELLOW}Enabling PM trace...${NC}"
    echo 1 | sudo tee /sys/power/pm_trace > /dev/null
    echo -e "${GREEN}PM trace enabled${NC}"
}

# Function to disable PM tracing
disable_pm_trace() {
    echo -e "${YELLOW}Disabling PM trace...${NC}"
    echo 0 | sudo tee /sys/power/pm_trace > /dev/null
    echo -e "${GREEN}PM trace disabled${NC}"
}

# Function to enable debug messages
enable_debug_messages() {
    echo -e "${YELLOW}Enabling PM debug messages...${NC}"
    echo 1 | sudo tee /sys/power/pm_debug_messages > /dev/null
    echo -e "${GREEN}PM debug messages enabled${NC}"
}

# Function to show suspend statistics
show_suspend_stats() {
    echo -e "${YELLOW}=== Suspend Statistics ===${NC}"
    if [ -f /sys/kernel/debug/suspend_stats ]; then
        sudo cat /sys/kernel/debug/suspend_stats
    else
        echo -e "${RED}Suspend stats not available (mount debugfs)${NC}"
    fi
}

# Function to set PM test mode
set_pm_test() {
    local mode="$1"
    echo -e "${YELLOW}Setting PM test mode to: $mode${NC}"
    echo "$mode" | sudo tee /sys/power/pm_test > /dev/null
    echo -e "${GREEN}PM test mode set to: $mode${NC}"
}

# Function to check PM trace device match
check_pm_trace_match() {
    echo -e "${YELLOW}=== PM Trace Device Match ===${NC}"
    if [ -f /sys/power/pm_trace_dev_match ]; then
        sudo cat /sys/power/pm_trace_dev_match
    else
        echo -e "${RED}PM trace device match not available${NC}"
    fi
}

# Function to mount debugfs
mount_debugfs() {
    if ! mount | grep -q debugfs; then
        echo -e "${YELLOW}Mounting debugfs...${NC}"
        sudo mount -t debugfs none /sys/kernel/debug
        echo -e "${GREEN}Debugfs mounted${NC}"
    else
        echo -e "${GREEN}Debugfs already mounted${NC}"
    fi
}

# Function to capture logs before suspend
capture_pre_suspend() {
    echo -e "${YELLOW}Capturing pre-suspend logs...${NC}"
    mkdir -p /home/christopher/Scripts/installation/newLinuxInstall/suspend.logs
    dmesg > /home/christopher/Scripts/installation/newLinuxInstall/suspend.logs/pre-suspend-$(date +%Y%m%d-%H%M%S).log
    echo -e "${GREEN}Pre-suspend logs captured${NC}"
}

# Function to capture logs after resume
capture_post_resume() {
    echo -e "${YELLOW}Capturing post-resume logs...${NC}"
    mkdir -p /home/christopher/Scripts/installation/newLinuxInstall/suspend.logs
    dmesg > /home/christopher/Scripts/installation/newLinuxInstall/suspend.logs/post-resume-$(date +%Y%m%d-%H%M%S).log
    echo -e "${GREEN}Post-resume logs captured${NC}"
}

# Main menu
case "$1" in
    "enable-trace")
        mount_debugfs
        enable_pm_trace
        enable_debug_messages
        ;;
    "disable-trace")
        disable_pm_trace
        ;;
    "stats")
        mount_debugfs
        show_suspend_stats
        ;;
    "test-devices")
        set_pm_test "devices"
        ;;
    "test-platform")
        set_pm_test "platform"
        ;;
    "test-processors")
        set_pm_test "processors"
        ;;
    "test-core")
        set_pm_test "core"
        ;;
    "test-none")
        set_pm_test "none"
        ;;
    "check-match")
        check_pm_trace_match
        ;;
    "pre-suspend")
        capture_pre_suspend
        ;;
    "post-resume")
        capture_post_resume
        ;;
    "setup")
        mount_debugfs
        enable_pm_trace
        enable_debug_messages
        echo -e "${GREEN}=== Debug setup complete ===${NC}"
        echo -e "${YELLOW}Ready for suspend testing. Use 'systemctl suspend' to test.${NC}"
        ;;
    *)
        echo "Usage: $0 {enable-trace|disable-trace|stats|test-devices|test-platform|test-processors|test-core|test-none|check-match|pre-suspend|post-resume|setup}"
        echo ""
        echo "Commands:"
        echo "  enable-trace   - Enable PM tracing and debug messages"
        echo "  disable-trace  - Disable PM tracing"
        echo "  stats          - Show suspend statistics"
        echo "  test-devices   - Test device suspend/resume only"
        echo "  test-platform  - Test platform (ACPI) suspend/resume"
        echo "  test-processors- Test processor suspend/resume"
        echo "  test-core      - Test core suspend/resume"
        echo "  test-none      - Normal suspend/resume (disable test mode)"
        echo "  check-match    - Check PM trace device match"
        echo "  pre-suspend    - Capture logs before suspend"
        echo "  post-resume    - Capture logs after resume"
        echo "  setup          - Complete debug setup"
        ;;
esac