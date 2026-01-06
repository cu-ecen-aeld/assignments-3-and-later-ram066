#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Error: Two arguments required"
    echo "Usage: $0 <writefile> <writestr>"
    exit 1
fi

writefile="$1"
writestr="$2"

writedir=$(dirname "$writefile")

mkdir -p "$writedir" || exit 1
echo "$writestr" > "$writefile" || exit 1
