#!/usr/bin/env bash

set -u

PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

echo "======================================"
echo " Assignment 1 - Local Grader"
echo " Linux / Bash / Networking / Git"
echo "======================================"
echo

# Check required files.
for file in README.md system-info.sh disk-check.sh network-check.sh; do
    if [[ -f "$file" ]]; then
        pass "Required file exists: $file"
    else
        fail "Missing required file: $file"
    fi
done

# Check the logs directory.
if [[ -d logs ]]; then
    pass "Logs directory exists"
else
    fail "Logs directory is missing"
fi

mkdir -p logs

# Check Bash syntax.
for file in system-info.sh disk-check.sh network-check.sh; do
    if [[ -f "$file" ]]; then
        if bash -n "$file"; then
            pass "Bash syntax: $file"
        else
            fail "Bash syntax error: $file"
        fi
    fi
done

# Check executable permissions.
for file in system-info.sh disk-check.sh network-check.sh; do
    if [[ -x "$file" ]]; then
        pass "Executable: $file"
    else
        fail "Not executable: $file"
    fi
done

# Test system-info.sh.
if [[ -x ./system-info.sh ]]; then
    output=$(./system-info.sh 2>&1)
    rc=$?

    if [[ $rc -eq 0 ]]; then
        pass "system-info.sh exits successfully"
    else
        fail "system-info.sh returned exit code $rc"
    fi

    for term in hostname user kernel uptime; do
        if grep -qi "$term" <<< "$output"; then
            pass "System information contains '$term'"
        else
            fail "System information is missing '$term'"
        fi
    done
fi

# Test disk-check.sh input validation.
if [[ -x ./disk-check.sh ]]; then
    ./disk-check.sh 0 >/dev/null 2>&1
    rc=$?

    if [[ $rc -eq 2 ]]; then
        pass "Rejects threshold 0"
    else
        fail "Should reject threshold 0 with exit code 2"
    fi

    ./disk-check.sh 101 >/dev/null 2>&1
    rc=$?

    if [[ $rc -eq 2 ]]; then
        pass "Rejects threshold 101"
    else
        fail "Should reject threshold 101 with exit code 2"
    fi

    ./disk-check.sh abc >/dev/null 2>&1
    rc=$?

    if [[ $rc -eq 2 ]]; then
        pass "Rejects non-numeric threshold"
    else
        fail "Should reject non-numeric threshold with exit code 2"
    fi

    ./disk-check.sh 100 / >/dev/null 2>&1
    rc=$?

    if [[ $rc -eq 0 || $rc -eq 1 ]]; then
        pass "Accepts valid threshold and path"
    else
        fail "Unexpected result for valid threshold and path"
    fi
fi

# Test network-check.sh input validation.
if [[ -x ./network-check.sh ]]; then
    ./network-check.sh >/dev/null 2>&1
    rc=$?

    if [[ $rc -ne 0 ]]; then
        pass "Rejects missing host"
    else
        fail "Should reject missing host"
    fi

    ./network-check.sh localhost >/dev/null 2>&1
    rc=$?

    if [[ $rc -eq 0 || $rc -eq 1 ]]; then
        pass "Accepts localhost as host input"
    else
        fail "Unexpected result for localhost"
    fi

    for port in 0 65536 abc; do
        ./network-check.sh localhost "$port" >/dev/null 2>&1
        rc=$?

        if [[ $rc -eq 2 ]]; then
            pass "Rejects invalid port: $port"
        else
            fail "Should reject invalid port: $port"
        fi
    done
fi

# Check logging.
if [[ -f logs/diagnostics.log ]] &&
   grep -qE '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} ' logs/diagnostics.log; then
    pass "Timestamped log entries exist"
else
    fail "Timestamped log entries are missing"
fi

# Check Git history if this is a Git repository.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    commits=$(git rev-list --count HEAD)

    if (( commits >= 5 )); then
        pass "At least five Git commits exist"
    else
        fail "Fewer than five Git commits exist"
    fi

    branches=$(git for-each-ref --format='%(refname:short)' refs/heads |
        grep -vE '^(main|master)$' | wc -l)

    if (( branches >= 1 )); then
        pass "A non-main local branch exists"
    else
        fail "No non-main local branch exists"
    fi
else
    echo "INFO: Git checks skipped because this is not a Git repository yet."
fi

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

if (( FAIL > 0 )); then
    exit 1
fi

exit 0
