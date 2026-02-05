#!/bin/bash

# bg_move.sh: Move files in a directory to a backup subdirectory in background.
# Usage: ./bg_move.sh <directory>
# For each regular file in the specified directory (non-recursive), the script
# moves it to a subdirectory called backup/ using `mv` in background and
# prints the PID of each background move. After starting all move operations,
# it waits for all of them to finish.

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

dir="$1"

if [ ! -d "$dir" ]; then
    echo "Error: '$dir' is not a directory or does not exist." >&2
    exit 1
fi

backup_dir="$dir/backup"
mkdir -p "$backup_dir"

declare -a pids

for f in "$dir"/*; do
    # skip directories and skip the backup directory itself
    [ "$f" = "$backup_dir" ] && continue
    [ -f "$f" ] || continue
    mv "$f" "$backup_dir/" &
    pid=$!
    echo "Moved $(basename "$f") in background with PID $pid"
    pids+=("$pid")
done

echo "Waiting for background processes to finish..."
for pid in "${pids[@]}"; do
    wait "$pid"
done
echo "All background processes completed."