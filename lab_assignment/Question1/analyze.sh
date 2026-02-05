#!/bin/bash

# analyze.sh: Determine information about a file or directory.
# Accepts exactly one command‑line argument. Based on the argument type, the
# script computes different statistics:
#   * If the argument is a regular file, it prints the number of lines,
#     words, and characters in the file using the `wc` command.
#   * If the argument is a directory, it prints the total number of files
#     contained within that directory (recursively) and the number of files
#     with a `.txt` extension.
#   * If the argument count is not one or the path does not exist, it
#     displays an appropriate error message.

# Check the number of arguments supplied
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_or_directory>" >&2
    exit 1
fi

path="$1"

# Validate that the supplied path exists
if [ ! -e "$path" ]; then
    echo "Error: path '$path' does not exist." >&2
    exit 1
fi

# Case: argument is a regular file
if [ -f "$path" ]; then
    # Use wc to get lines, words, and characters. The output is
    # in the order: lines words characters filename
    read -r lines words chars _ < <(wc "$path")
    echo "File statistics for '$path':"
    echo "Lines: $lines"
    echo "Words: $words"
    echo "Characters: $chars"
    exit 0
fi

# Case: argument is a directory
if [ -d "$path" ]; then
    # Count all files (excluding directories) in the directory recursively
    total_files=$(find "$path" -type f | wc -l)
    # Count all .txt files (case-insensitive) in the directory recursively
    txt_files=$(find "$path" -type f -iname "*.txt" | wc -l)
    echo "Directory statistics for '$path':"
    echo "Total files: $total_files"
    echo "Number of .txt files: $txt_files"
    exit 0
fi

# If it is neither a file nor a directory, report an unsupported type
echo "Error: '$path' is neither a regular file nor a directory." >&2
exit 1