# Assignment 1 Testing Notes

## System Information

* Run `./system-info.sh`.
* Confirm that hostname, user, kernel and uptime information are displayed.

## Disk Usage

* Run `./disk-check.sh 80 /`.
* Run `./disk-check.sh 0` and confirm exit code 2.
* Run `./disk-check.sh 101` and confirm exit code 2.
* Run `./disk-check.sh abc` and confirm exit code 2.

## Network Diagnostics

* Run `./network-check.sh localhost`.
* Run `./network-check.sh localhost 0` and confirm exit code 2.
* Run `./network-check.sh localhost 65536` and confirm exit code 2.
* Run `./network-check.sh localhost abc` and confirm exit code 2.

## Logging

* Run the disk and network scripts.
* Confirm that `logs/diagnostics.log` contains timestamped entries.
