#!/bin/bash

# create_troubleshooting_file.sh

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run with administrative privileges. Please run with sudo."
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TROUBLESHOOT_FILE="troubleshooting_$TIMESTAMP.txt"

echo "Creating troubleshooting file: $TROUBLESHOOT_FILE"

{
    echo "=== System Information ==="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo "Logged in users:"
    who
    echo

    echo "=== Operating System ==="
    lsb_release -a 2>/dev/null || cat /etc/os-release
    echo

    echo "=== Docker Info ==="
    docker info
    echo

    echo "=== Docker Containers ==="
    docker ps -a
    echo

    echo "=== Docker Images ==="
    docker images
    echo

    echo "=== Environment Variables ==="
    # Exclude sensitive variables
    env | grep -v -E 'RIVEN_PLEX_TOKEN|RIVEN_PLEX_URL|RIVEN_DOWNLOADERS_REAL_DEBRID_API_KEY'
    echo

    echo "=== docker-compose.yml Contents ==="
    # Mask sensitive information in docker-compose.yml
    sed -e 's/\(RIVEN_PLEX_TOKEN:\).*/\1 [MASKED]/' \
        -e 's/\(RIVEN_DOWNLOADERS_REAL_DEBRID_API_KEY:\).*/\1 [MASKED]/' \
        docker-compose.yml
    echo

    echo "=== Disk Usage ==="
    df -h
    echo

    echo "=== Network Configuration ==="
    ip addr show
    echo

    echo "=== Running Processes ==="
    ps aux
    echo

} > "$TROUBLESHOOT_FILE"

echo "Troubleshooting file created: $TROUBLESHOOT_FILE"
