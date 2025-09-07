#!/bin/sh
(cd ../../../slint
find . -name "*.dep"|while read i;do j=$(cat $i|sed 's#,#\n#g'|wc -l);printf "%b" "$j ";echo $i; done|sort -n >/tmp/nbdeps.txt
)
