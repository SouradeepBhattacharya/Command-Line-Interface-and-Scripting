#!/bin/bash

# logsummary.sh: Analyze a log file and produce a summary report.
# Usage: ./logsummary.sh <logfile>
# The script validates that the given log file exists and is readable. It then
# counts total log entries, counts the number of INFO, WARNING, and ERROR
# messages, extracts the most recent ERROR message, and writes a summary
# report to a file named logsummary_<YYYY-MM-DD>.txt in the current
# directory.

set -e

# Function to print an error message to stderr
error() {
    echo "Error: $1" >&2
}

# Validate argument count
if [ "$#" -ne 1 ]; then
    error "Usage: $0 <logfile>"
    exit 1
fi

logfile="$1"

# Validate log file exists and is readable
if [ ! -e "$logfile" ]; then
    error "File '$logfile' does not exist."
    exit 1
fi

if [ ! -r "$logfile" ]; then
    error "File '$logfile' is not readable."
    exit 1
fi

# Count total number of log entries (lines)
total_entries=$(wc -l < "$logfile")

# Count occurrences of each log level. The pattern matches whitespace
# before the level to reduce false positives.
info_count=$(grep -c "\bINFO\b" "$logfile" || true)
warning_count=$(grep -c "\bWARNING\b" "$logfile" || true)
error_count=$(grep -c "\bERROR\b" "$logfile" || true)

# Get the most recent ERROR message (last occurrence)
recent_error=$(grep "\bERROR\b" "$logfile" | tail -n 1 || true)

# Display summary to the user
echo "Log summary for '$logfile':"
echo "Total entries: $total_entries"
echo "INFO messages: $info_count"
echo "WARNING messages: $warning_count"
echo "ERROR messages: $error_count"

if [ -n "$recent_error" ]; then
    echo "Most recent ERROR: $recent_error"
else
    echo "Most recent ERROR: None"
fi

# Create a report file with the date stamp
report_date=$(date +%Y-%m-%d)
report_file="logsummary_${report_date}.txt"

{
    echo "Log Summary Report (generated on $report_date)"
    echo "Log file: $logfile"
    echo "Total entries: $total_entries"
    echo "INFO messages: $info_count"
    echo "WARNING messages: $warning_count"
    echo "ERROR messages: $error_count"
    if [ -n "$recent_error" ]; then
        echo "Most recent ERROR: $recent_error"
    else
        echo "Most recent ERROR: None"
    fi
} > "$report_file"

echo "Report written to $report_file"

exit 0