#!/bin/sh
# Author: Didier Spaier, Paris, France
# Public domain
CWD=$(pwd)
usage() {
  printf %b "Usage: $0\n"
  exit
}
export MAINREPO=slint
BASEDIR=/repo

if [ $UID -eq 0 ]; then
  printf "%b"  "Please execute this script as regular user.\n"
  exit
fi



SLINTREPO=$BASEDIR/x86_64/slint-15.0
	( cd $SLINTREPO || exit 1
		$CWD/metagen.sh all
		$CWD/metagen.sh md5
	)

#$BASEDIR/i586/slint-14.2 \
#$BASEDIR/x86_64/slint-14.2 \
#$BASEDIR/x86_64/slint-14.2.1 \
#$BASEDIR/i586/slint-14.2 \
#$BASEDIR/x86_64/slint-14.2 \
#$BASEDIR/i586/slint-14.2 \
#$BASEDIR/x86_64/slint-14.2.1 \
