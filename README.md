# Assignment 1: Linux, Bash and Networking

## Overview

This project contains a Linux diagnostic toolkit written in Bash. It collects system information, checks disk usage, performs basic network diagnostics, and records operations in log files.

## Project Structure

```text
assignment-1/
├── README.md
├── system-info.sh
├── disk-check.sh
├── network-check.sh
├── grade.sh
└── logs/
    ├── .gitkeep
    └── diagnostics.log
```

## Requirements

* Linux environment or Ubuntu through Windows Subsystem for Linux (WSL).
* Bash.
* Standard Linux utilities such as `hostname`, `uname`, `df`, `awk`, `getent`, and `ip`.
* Git for version control.

## Setup

Clone the repository:

```bash
git clone <your-repository-url>
cd assignment-1
```

Make the scripts executable:

```bash
chmod +x system-info.sh disk-check.sh network-check.sh grade.sh
```

Create the log directory if it does not exist:

```bash
mkdir -p logs
```

## Usage

### 1. System Information

```bash
./system-info.sh
```

Displays the hostname, current user, date and time, operating system, kernel version, uptime, CPU information, memory information, and current working directory.

### 2. Disk Usage

```bash
./disk-check.sh <threshold> [path]
```

Example:

```bash
./disk-check.sh 80 /
```

The threshold must be an integer from 1 to 100. If no path is supplied, the script checks `/`.

Exit codes:

* `0`: Disk usage is below the threshold.
* `1`: Disk usage reaches or exceeds the threshold, or an operational error occurs.
* `2`: Invalid input.

### 3. Network Diagnostics

```bash
./network-check.sh <hostname-or-ip> [port]
```

Examples:

```bash
./network-check.sh localhost
./network-check.sh google.com
./network-check.sh google.com 443
```

The script resolves the supplied host, performs a basic connectivity check, displays network interface information, and optionally checks TCP connectivity to a supplied port.

Valid ports range from 1 to 65535.

Exit codes:

* `0`: The requested diagnostic completed successfully.
* `1`: A host resolution or TCP connectivity operation failed.
* `2`: Invalid arguments or input.

Ping failures may occur when ICMP traffic is blocked by a network or host.

## Logging

Operations are recorded in:

```text
logs/diagnostics.log
```

Log entries contain a timestamp and a description of the operation.

The log file is generated when the scripts run.

## Testing

Run the following commands:

```bash
./system-info.sh
./disk-check.sh 80 /
./disk-check.sh 0
./network-check.sh localhost
./network-check.sh localhost 0
```

Check the generated log:

```bash
cat logs/diagnostics.log
```

When available, run the local grading script:

```bash
./grade.sh
```

## Git Workflow

The project uses Git for version control. Meaningful commits and a feature branch are used to document development.

## Assumptions and Limitations

* The scripts are designed for a Linux environment.
* Network connectivity tests may be affected by DNS configuration, firewall rules, or blocked ICMP traffic.
* Disk usage depends on the filesystem containing the selected path.
* No cloud deployment is required.
