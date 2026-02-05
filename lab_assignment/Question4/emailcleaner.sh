#!/bin/bash

# emailcleaner.sh: Separate valid and invalid email addresses from emails.txt.
# A valid email has the format: <letters_and_digits>@<letters>.com
# That is: before the '@' only letters (uppercase or lowercase) and digits;
# after the '@' only letters (no digits or hyphens), followed by `.com`.
# The script writes unique valid emails to valid.txt (duplicates removed)
# and invalid emails to invalid.txt. Both output files are created in the
# current directory.

set -e

input_file="emails.txt"
valid_file="valid.txt"
invalid_file="invalid.txt"

# Check that the input file exists
if [ ! -e "$input_file" ]; then
    echo "Error: '$input_file' not found in the current directory." >&2
    exit 1
fi

# Use grep with extended regex to match valid emails.
# The pattern matches lines that begin (^) with one or more letters or digits,
# then an '@' symbol, then one or more letters, and end with '.com' ($).
pattern='^[A-Za-z0-9]+@[A-Za-z]+\.com$'

# Filter valid and invalid emails
grep -E "$pattern" "$input_file" > tmp_valid_list.txt || true
grep -Ev "$pattern" "$input_file" > "$invalid_file" || true

# Remove duplicates from valid emails and write to final file
if [ -s tmp_valid_list.txt ]; then
    sort tmp_valid_list.txt | uniq > "$valid_file"
else
    # If no valid emails, create an empty file
    : > "$valid_file"
fi

# Clean up temporary file
rm -f tmp_valid_list.txt

echo "Valid email addresses have been saved to '$valid_file'."
echo "Invalid email addresses have been saved to '$invalid_file'."