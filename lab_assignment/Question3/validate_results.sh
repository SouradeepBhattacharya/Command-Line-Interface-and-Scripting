#!/bin/bash

# validate_results.sh: Analyze student marks and determine pass/fail status.
# The input file marks.txt is expected to be in the current directory. Each
# line has the format: RollNo,Name,Marks1,Marks2,Marks3
# Passing marks for each subject is 33. The script classifies students into
# those who failed exactly one subject and those who passed all subjects.
# It prints the names (and roll numbers) of students in each category and
# reports the count of students in each category at the end.

set -e

marks_file="marks.txt"

# Check that the input file exists and is readable
if [ ! -e "$marks_file" ]; then
    echo "Error: '$marks_file' not found in the current directory." >&2
    exit 1
fi
if [ ! -r "$marks_file" ]; then
    echo "Error: '$marks_file' is not readable." >&2
    exit 1
fi

pass_all_count=0
fail_one_count=0

# Create (or truncate) files to store lists of students. Do not include
# headers here; headers are printed to stdout later.
: > failed_one.txt
: > passed_all.txt

while IFS=',' read -r roll name m1 m2 m3; do
    # Trim whitespace around fields (in case of spaces after commas)
    roll=$(echo "$roll" | xargs)
    name=$(echo "$name" | xargs)
    m1=$(echo "$m1" | xargs)
    m2=$(echo "$m2" | xargs)
    m3=$(echo "$m3" | xargs)

    # Count the number of subjects with marks below 33
    fails=0
    [ "$m1" -lt 33 ] && fails=$((fails + 1))
    [ "$m2" -lt 33 ] && fails=$((fails + 1))
    [ "$m3" -lt 33 ] && fails=$((fails + 1))

    if [ "$fails" -eq 0 ]; then
        # Passed all subjects
        echo "$roll - $name" >> passed_all.txt
        pass_all_count=$((pass_all_count + 1))
    elif [ "$fails" -eq 1 ]; then
        # Failed exactly one subject
        echo "$roll - $name" >> failed_one.txt
        fail_one_count=$((fail_one_count + 1))
    fi
done < "$marks_file"

# Print results to stdout
echo "Students who failed in exactly one subject:"
if [ -s failed_one.txt ]; then
    cat failed_one.txt
else
    echo "None"
fi

echo
echo "Students who passed in all subjects:"
if [ -s passed_all.txt ]; then
    cat passed_all.txt
else
    echo "None"
fi

echo
echo "Summary:"
echo "Count of students who failed exactly one subject: $fail_one_count"
echo "Count of students who passed in all subjects: $pass_all_count"