#!/bin/bash

INFILE="$1"
OUTFILE="${INFILE%.*}.md"
TXTFILE="${INFILE%.*}.txt"
CSLDIR="$(dirname "$TXTFILE")"
FILTERS="filters"

if [ -f "$OUTFILE" ]; then
    echo "Output file $OUTFILE already exists, doing nothing."
    echo "If you want to convert the file again, delete the output file first."
    exit -1
fi

echo "Creating file $OUTFILE ... "

pandoc "$INFILE" \
    --output "$OUTFILE" \
    --to markdown-smart \
    --wrap none \
    --atx-headers \
    --reference-location block

status=$?
if [ $status -eq 0 ]; then
    echo "done."
else
    echo "error!"
    exit $status
fi

echo "Extracting citations ... "

pandoc "$INFILE" \
    --output "$TXTFILE" \
    --to markdown-smart \
    --wrap none \
    --filter "$FILTERS"/plaintext.py \
&& anystyle -f bib find "$TXTFILE" "$CSLDIR" \
&& rm "$TXTFILE" \
&& echo "done." \
|| echo "error!"
