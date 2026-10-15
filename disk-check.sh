#!/usr/bin/env bash

set -u

# Record the start time of the operation.
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Use the supplied threshold.
threshold="${1:-}"

# Use / when no path is supplied.
path="${2:-/}"

# Reject a missing or non-numeric threshold.
if [[ ! "$threshold" =~ ^[0-9]+$ ]]; then
    echo "Error: Threshold must be an integer from 1 to 100."
    exit 2
fi

# Reject thresholds outside the permitted range.
if (( threshold < 1 || threshold > 100 )); then
    echo "Error: Threshold must be between 1 and 100."
    exit 2
fi

# Confirm that the specified path exists.
if [[ ! -e "$path" ]]; then
    echo "Error: Path does not exist: $path"
    exit 2
fi

# Obtain disk usage as a percentage.
usage=$(df -P "$path" | awk 'NR == 2 {gsub(/%/, "", $5); print $5}')

# Handle failure to obtain disk usage.
if [[ ! "$usage" =~ ^[0-9]+$ ]]; then
    echo "Error: Unable to determine disk usage for $path"
    exit 1
fi

echo "Path: $path"
echo "Disk Usage: ${usage}%"
echo "Threshold: ${threshold}%"

# Create the logs directory if necessary.
mkdir -p logs

# Record the operation.
printf '[%s] Disk check: path=%s usage=%s%% threshold=%s%%\n' \
    "$timestamp" "$path" "$usage" "$threshold" >> logs/diagnostics.log

# Compare usage with the threshold.
if (( usage >= threshold )); then
    echo "WARNING: Disk usage has reached or exceeded the threshold."
    exit 1
else
    echo "OK: Disk usage is below the threshold."
    exit 0
fi
```
