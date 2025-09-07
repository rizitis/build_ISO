#!/bin/sh
cd .. 1>/dev/null ||  exit 1
ROOTDIR=$(pwd)
cd - 1>/dev/null || exit 1
CWD=$(pwd)
cd /data/repos/slackware-15.0/slackware64 || exit
find . -name "*.txz"|sed 's#.*/##;s#-[^-]*-[^-]*-[^-]*$##' >"$ROOTDIR"/files-in-initrd/slackware
cd "$ROOTDIR"/files-in-initrd || exit
while read i; do
	sed /"^$i$"/d slackware >bof
	mv bof slackware
done <bootstrapslack
cd "$CWD" || exit
