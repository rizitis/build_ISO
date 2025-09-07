#!/bin/sh
# Save me as deps_not_found.sh and run me as root
# This does only a very basic scanning. Caveats:
# 1. this finds only the missing binary files, not the missing python
#    perl, etc. scripts
# 2. There not guarantee that for instance a header file include the
#    needed definitions.
for i in $(find /usr/lib{,64} -name "*.so" -type f -executable) \
$(find /bin /usr/bin /sbin/ /usr/sbin /usr/libexec /opt/ /usr/local/bin -type f -executable); do
	if [ ! "$(ldd $i|grep found)" = "" ]; then
		echo $i
		ldd $i|grep found
	fi
done > /tmp/bindepsnotfound.txt
chown didier: /tmp/bindepsnotfound.txt
