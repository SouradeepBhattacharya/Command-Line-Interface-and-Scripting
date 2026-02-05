#!/bin/bash

# sync.sh: Compare two directories and report differences.
# Usage: ./sync.sh <dirA> <dirB>
# The script lists files present only in dirA, only in dirB, and for files
# with the same name in both directories (non‑recursive), checks whether
# their contents are identical. It does not copy or modify any files.

set -e

error() {
    echo "Error: $1" >&2
}

if [ "$#" -ne 2 ]; then
    error "Usage: $0 <dirA> <dirB>"
    exit 1
fi

dirA="$1"
dirB="$2"

# Validate directories
if [ ! -d "$dirA" ]; then
    error "'$dirA' is not a directory or does not exist."
    exit 1
fi
if [ ! -d "$dirB" ]; then
    error "'$dirB' is not a directory or does not exist."
    exit 1
fi

# Generate lists of file names (not paths) for non-recursive comparison.
# Only include regular files.
filesA=$(find "$dirA" -maxdepth 1 -type f -printf '%f\n' | sort)
filesB=$(find "$dirB" -maxdepth 1 -type f -printf '%f\n' | sort)

# Use temporary files for comm to work with sorted lists
tmpA=$(mktemp)
tmpB=$(mktemp)
printf '%s\n' "$filesA" > "$tmpA"
printf '%s\n' "$filesB" > "$tmpB"

echo "Files only in $dirA:" > only_in_A.txt
echo "Files only in $dirB:" > only_in_B.txt
echo "Comparison of files with the same name:" > comparison.txt

# List files only in dirA (comm output field 1)
comm -23 "$tmpA" "$tmpB" >> only_in_A.txt

# List files only in dirB (comm output field 2)
comm -13 "$tmpA" "$tmpB" >> only_in_B.txt

# Compare contents of files with same name (comm output field 3)
while IFS= read -r fname; do
    fileA="$dirA/$fname"
    fileB="$dirB/$fname"
    if cmp -s "$fileA" "$fileB"; then
        echo "$fname: identical" >> comparison.txt
    else
        echo "$fname: different" >> comparison.txt
    fi
done < <(comm -12 "$tmpA" "$tmpB")

# Display results
echo "Files present only in $dirA:"
if [ -s only_in_A.txt ]; then
    sed '1d' only_in_A.txt # skip header line
else
    echo "None"
fi

echo
echo "Files present only in $dirB:"
if [ -s only_in_B.txt ]; then
    sed '1d' only_in_B.txt
else
    echo "None"
fi

echo
echo "File content comparison (for files with the same name):"
if [ -s comparison.txt ]; then
    sed '1d' comparison.txt
else
    echo "No common files"
fi

# Clean up temporary files
rm -f "$tmpA" "$tmpB"