#!/usr/bin/env bash

set -u

echo "======================================"
echo "         SYSTEM INFORMATION"
echo "======================================"

echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Date and Time: $(date)"
echo "Operating System: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d '"' -f 2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "CPU Information:"

lscpu | grep -E 'Model name|Architecture|CPU\(s\)' | head -n 3

echo
echo "Memory Information:"

free -h

echo
echo "Current Working Directory: $(pwd)"

echo "======================================"
```
