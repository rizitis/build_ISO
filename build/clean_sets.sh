#!/bin/sh
# We do not want blank lines, leading or trailing white spaces
# in names of packages liste in sets
for file in "$ROOTDIR"/sets/*; do
    [ -f "$file" ] || continue
    sed -e '/^[[:space:]]*$/d' \
        -e 's/^[[:space:]]*//' \
        -e 's/[[:space:]]*$//' \
        "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done
