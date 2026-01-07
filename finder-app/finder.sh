#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 2 ]; then
 echo "Error:Two arguments required usage: <filedir> <searchdir>"
 exit 1
fi
filedir="$1"
searchstr="$2"
if [ ! -d "$filedir" ]; then
 echo "error: $filedir is not valid directory"
 exit 1
fi
 
 X=$(find "$filedir" -type f | wc -l)
 Y=$(grep -R -F -I "$searchstr" "$filedir" 2>/dev/null | wc -l)
 
 echo "The number of files are $X and the number of matching lines are $Y"
