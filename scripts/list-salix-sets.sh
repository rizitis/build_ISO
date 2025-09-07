#!/bin/sh
DEST=/repo/x86_64/slint-15.0/source/build_ISO/sets
(cd /mnt/salix || exit
for SET in *; do
	rm -f "$DEST/$SET"	
	find "$SET" -name "*txz"|sed 's#.*/##;s#-[^-]*-[^-]*-[^-]*$##'|while read NAME; do
		echo "$NAME" >> "$DEST/$SET"
	done
done
mv "$DEST/full" "$DEST/fullsalix"
)
