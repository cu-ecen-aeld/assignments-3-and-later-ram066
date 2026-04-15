#!/bin/sh
set -e
set -u

NUMFILES=10
WRITESTR=AELD_IS_FUN
WRITEDIR=/tmp/aeld-data

TEST_DIR=/tmp/aesd-test
mkdir -p $TEST_DIR

echo "hello world" > $TEST_DIR/file1.txt
echo "hello AESD" > $TEST_DIR/file2.txt
echo "no match here" > $TEST_DIR/file3.txt

# FIXED: removed ./
finder.sh $TEST_DIR hello > /tmp/assignment4-result.txt

cat /tmp/assignment4-result.txt

if [ $# -ge 1 ]; then
    NUMFILES=$1
fi

if [ $# -ge 2 ]; then
    WRITESTR=$2
fi

MATCHSTR="The number of files are ${NUMFILES} and the number of matching lines are ${NUMFILES}"

echo "Writing ${NUMFILES} files containing string ${WRITESTR} to ${WRITEDIR}"

rm -rf "${WRITEDIR}"
mkdir -p "${WRITEDIR}"

i=0
while [ $i -lt $NUMFILES ]
do
    writer "${WRITEDIR}/file${i}.txt" "${WRITESTR}"
    i=$((i+1))
done

# FIXED: removed ./
OUTPUTSTRING=$(finder.sh "${WRITEDIR}" "${WRITESTR}")

set +e
echo "${OUTPUTSTRING}" | grep "${MATCHSTR}"
if [ $? -eq 0 ]; then
    echo "success"
    exit 0
else
    echo "failed: expected ${MATCHSTR} in ${OUTPUTSTRING}"
    exit 1
fi
