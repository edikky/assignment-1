#!/usr/bin/env bash

set -u

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/diagnostics.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$LOG_DIR"

log_message() {
    printf '[%s] %s\n' "$TIMESTAMP" "$1" >> "$LOG_FILE"
}

# Validate the number of arguments.
if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 <hostname-or-ip> [port]"
    log_message "Network check failed: invalid number of arguments"
    exit 2
fi

host="$1"
port="${2:-}"

# Validate that the host is not empty or malformed.
if [[ -z "$host" || "$host" == -* || "$host" =~ [[:space:]] ]]; then
    echo "Error: Invalid hostname or IP address."
    log_message "Network check failed: invalid host argument"
    exit 2
fi

# Validate the optional port.
if [[ -n "$port" ]]; then
    if [[ ! "$port" =~ ^[0-9]+$ ]] || (( ${#port} > 5 )); then
        echo "Error: Port must be an integer between 1 and 65535."
        log_message "Network check failed: invalid port"
        exit 2
    fi

    if (( 10#$port < 1 || 10#$port > 65535 )); then
        echo "Error: Port must be between 1 and 65535."
        log_message "Network check failed: port out of range"
        exit 2
    fi

    port=$((10#$port))
fi

echo "======================================"
echo "         NETWORK DIAGNOSTICS"
echo "======================================"
echo "Host: $host"

log_message "Starting network check for $host"

# Resolve the hostname or IP address.
if command -v getent >/dev/null 2>&1; then
    resolved=$(getent ahosts "$host" 2>/dev/null | awk 'NR == 1 {print $1}')
else
    resolved=""
fi

if [[ -n "$resolved" ]]; then
    echo "Resolved Address: $resolved"
    log_message "Host $host resolved to $resolved"
else
    echo "Error: Unable to resolve host $host"
    log_message "Host resolution failed for $host"
    exit 1
fi

# Perform a basic connectivity check.
if command -v ping >/dev/null 2>&1; then
    if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
        echo "Connectivity: Successful (ping)"
        log_message "Ping to $host succeeded"
    else
        echo "Connectivity: Ping unsuccessful or blocked"
        log_message "Ping to $host failed or was blocked"
    fi
else
    echo "Connectivity: ping command is unavailable"
    log_message "Ping unavailable"
fi

# Display network interfaces.
echo
echo "Network Interfaces:"

if command -v ip >/dev/null 2>&1; then
    ip -brief address
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig
else
    echo "No supported network interface command found."
fi

# Check TCP connectivity if a port was supplied.
if [[ -n "$port" ]]; then
    echo
    echo "Checking TCP connectivity to $host:$port"

    if command -v timeout >/dev/null 2>&1 &&
       timeout 4 bash -c 'exec 3<>/dev/tcp/"$1"/"$2"' _ "$host" "$port" 2>/dev/null; then
        echo "TCP Connectivity: Successful"
        log_message "TCP connection to $host:$port succeeded"
    else
        echo "TCP Connectivity: Failed"
        log_message "TCP connection to $host:$port failed"
        exit 1
    fi
fi

echo
echo "Network diagnostic completed."
log_message "Network diagnostic completed for $host"

exit 0
```
