#!/bin/sh
set -e
set -u

CONFIG_FILE="/etc/finder-app/conf/assignment.conf"

filesdir=$(grep "^filesdir=" "$CONFIG_FILE" | cut -d '=' -f2)
searchstr=$(grep "^searchstr=" "$CONFIG_FILE" | cut -d '=' -f2)

finder.sh "$filesdir" "$searchstr" > /tmp/assignment4-result.txt

exit 0
