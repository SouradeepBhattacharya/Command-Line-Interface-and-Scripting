#!/bin/bash

# metrics.sh: Analyze a text file and compute word metrics.
# Usage: ./metrics.sh <input_file>
# The script computes the longest word, shortest word, average word length,
# and the total number of unique words. Words are defined as sequences of
# alphanumeric characters (letters and digits). Case is ignored when
# determining uniqueness and when reporting longest/shortest words.

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

file="$1"

# Validate that file exists and is readable
if [ ! -e "$file" ]; then
    echo "Error: File '$file' does not exist." >&2
    exit 1
fi
if [ ! -r "$file" ]; then
    echo "Error: File '$file' is not readable." >&2
    exit 1
fi

# Extract words: convert non-alphanumeric characters to newlines, convert to
# lowercase, and remove empty lines.
words=$(tr -cs '[:alnum:]' '\n' < "$file" | tr '[:upper:]' '[:lower:]' | awk 'length>0')

# Find the longest word
longest_word=$(echo "$words" | awk '{ if (length($0) > length(max)) { max=$0 } } END { print max }')

# Find the shortest word
shortest_word=$(echo "$words" | awk 'NR==1{ min=$0; minlen=length($0) } { if (length($0) < minlen) { min=$0; minlen=length($0) } } END { print min }')

# Compute average word length (total characters divided by total words)
read total_chars total_words <<< $(echo "$words" | awk '{ chars += length($0); count += 1 } END { print chars, count }')
if [ "$total_words" -eq 0 ]; then
    avg_length=0
else
    avg_length=$(awk -v c="$total_chars" -v n="$total_words" 'BEGIN { printf "%.2f", c/n }')
fi

# Total number of unique words
unique_count=$(echo "$words" | sort | uniq | wc -l)

echo "Text metrics for '$file':"
echo "Longest word: $longest_word"
echo "Shortest word: $shortest_word"
echo "Average word length: $avg_length"
echo "Total unique words: $unique_count"