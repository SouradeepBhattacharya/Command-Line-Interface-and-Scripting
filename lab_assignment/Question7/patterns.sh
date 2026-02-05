#!/bin/bash

# patterns.sh: Categorize words in a text file based on vowel/consonant patterns.
# Usage: ./patterns.sh <input_file>
# The script reads words (alphabetic sequences) from the input file, ignoring case.
# It writes words containing only vowels to vowels.txt, words containing only consonants
# to consonants.txt, and words containing both vowels and consonants but starting
# with a consonant to mixed.txt. Case is ignored when checking patterns.

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>" >&2
    exit 1
fi

file="$1"

if [ ! -e "$file" ]; then
    echo "Error: File '$file' does not exist." >&2
    exit 1
fi
if [ ! -r "$file" ]; then
    echo "Error: File '$file' is not readable." >&2
    exit 1
fi

# Output files
vowel_file="vowels.txt"
consonant_file="consonants.txt"
mixed_file="mixed.txt"

# Truncate output files
: > "$vowel_file"
: > "$consonant_file"
: > "$mixed_file"

# Convert non‑letters to newlines and iterate over words
tr -cs '[:alpha:]' '\n' < "$file" | while read -r word; do
    # Convert to lowercase
    w=$(echo "$word" | tr '[:upper:]' '[:lower:]')
    # Skip empty lines
    [ -z "$w" ] && continue
    # Check patterns
    if [[ "$w" =~ ^[aeiou]+$ ]]; then
        # Only vowels
        echo "$w" >> "$vowel_file"
    elif [[ "$w" =~ ^[bcdfghjklmnpqrstvwxyz]+$ ]]; then
        # Only consonants
        echo "$w" >> "$consonant_file"
    else
        # Contains both vowels and consonants
        # Ensure it starts with a consonant and has at least one vowel
        if [[ "$w" =~ ^[bcdfghjklmnpqrstvwxyz] && "$w" =~ [aeiou] ]]; then
            echo "$w" >> "$mixed_file"
        fi
    fi
done

echo "Words containing only vowels written to $vowel_file"
echo "Words containing only consonants written to $consonant_file"
echo "Words containing both vowels and consonants (starting with a consonant) written to $mixed_file"