#!/bin/sh
set -e
if [ $# -ne 2 ]; then
    echo "Error: Two arguments required"
    echo "Usage: $0 <filesdir> <searchstr>"
    exit 1
fi

filesdir="$1"
searchstr="$2"

if [ ! -d "$filesdir" ]; then
    echo "Error: $filesdir is not a valid directory"
    exit 1
fi

X=$(find "$filesdir" -type f 2>/dev/null | wc -l)
Y=$(grep -r -F "$searchstr" "$filesdir" 2>/dev/null | wc -l)

echo "The number of files are $X and the number of matching lines are $Y"
