#!/bin/sh
# This script builds a Slint ISO

# To use this script do this
# 1. (create if need be then) cd to a directory owned by a regular user
# 2. type as regular user:
#    git clone https://github.com/DidierSpaier/build_ISO
#    cd build_ISO
#    sh build_Slint_ISO.sh

# Here is the layout of the repository https://github.com/DidierSpaier/build_ISO:
# build/    Scripts used for building components of the initramfs and the ISO
# unused    Files not used to build a Slint ISO, some were used to build a Salix or Slackware ISO
# fonts/    fonts added to the initramfs matching the locales in which it is translated
# grub/     grub.cfg adapted to Salix, Slackware and Slint
# misc/     Miscellaneous files, see CONTENT in this directory
# sets/     Lists the sets of packages to be installed or added to the iniramfs. Thos used to build
#           the ISO for a distribution are listed in build/set_variables_<distribution>
                     
# Build_Slint_ISO.sh This shell script
# README.TXT         Describes how to build an ISO to install Salix, Slackware or Slint

# In addition, these files and directories as populated building the ISO and can be (re)moved
# when done:
# initrd-tree/ tree of the unpacked genuine Slackware64-15.0 customized by the script build/initrd
# isodir/ Files to included in the ISO
# initrd genuine Slackware initrd
# <filename>.iso The ISO file written using this scripts intended to install Slint
#
press_enter_to_continue() {
	if [ "$#" -eq 1 ]; then 
		echo "$1"
	else
		printf "Press Enter to continue..."
	fi
	read -r dummy
	echo "$dummy" > /dev/null
}
if [ ! -x /usr/sbin/slapt-get ]; then
	echo "slapt-get is needed to build the ISO."
	echo "You can run the SlackBuild available at https://slackbuilds.org"
	echo "or at time of writing get and install this package:"
	echo "https://slackware.uk/slint/x86_64/slint-15.0/slint/slapt-get-0.11.11-x86_64-4slint.txz"
	exit
fi
if [ ! -x /sbin/spkg ]; then
	echo "spkg is needed to build the ISO."
	echo "At time of writing you can get and install this package:"
	echo "https://slackware.uk/slint/x86_64/slint-15.0/slint/spkg-1.6-x86_64-2slint.txz"
	exit
fi
if [ ! -x /usr/bin/grub-mkrescue-sed.sh ]; then
	echo "You need the script grub-mkrescue-sed.sh to build the ISO."
	echo "At time of writing you can get it installing (or upgrading to) this package:"
	echo "https://slackware.uk/slint/x86_64/slint-15.0/slint/xorriso-1.5.6.pl02-x86_64-2slint.txz"
	exit
fi	
# This directory should be owned by a regular user
[ "$REGULARUSER" = root ] && echo "Do not run this script in a directory owned by root!" && exit
. build/set_variables_slint
press_enter_to_continue "We need to put 10G of files in this directory. If that's OK press Enter else press ctrl-C."
# In the file build/set_variables_slint, update the kernel version KVER and ISOVERSION if need be
echo "The ISO version is ISOVERSION=$ISOVERSION."
press_enter_to_continue "If that's OK press Enter, else press ctrl-C and update it in ./set_variables_slint."
echo "Get the latest versions of scripts used during installation..."
sh build/get_scripts slint
echo
# Clean the sets in ./sets although it shouls have been done by the maintainer
sh build/clean_sets.sh
echo "Creating and populating the directory holding the packages,"
echo "from which the ISO will be written. This takes some time..."
su -c "sh build/iso_dir slint"
echo
# Check that all needed packages are put in the ISO  
NBPKG=0
for i in $SETS; do
    k=$(wc -l < "sets/$i")
    NBPKG=$((NBPKG + k))
done
NBPKGISO="$(find "$ISODIR"/slint -name "*.txz"|wc -l)"
[ ! "$NBPKG" -eq "$NBPKGISO" ] && \
echo "There should be $NBPKG in $ISODIR but there are ${NBPKGISO}." \
&& exit
echo "Unpack Slackware's initramfs, customize it and put it into place..."
su -c 'sh build/initrd slint'
press_enter_to_continue "A file $ISODIR/initrd has been written. Press Enter to continue"
echo "Adding the package's metadata. This takes a long time..."
sh build/metadata slint 1>>LOG_build_ISO
echo
echo "You may now gpg sign the file $ISODIR/CHECKSUMS.md5.gz"
echo "You may also store your public gpg key as $ISODIR/GPG-KEY"
echo "For gpg version 2 (else replace gpg by gpg2 in the commands below),"
echo "you can do that typing:"
echo "gpg -sba $ISODIR/CHECKSUMS.md5.gz"
echo "gpg --armor --export <your public key> > $ISODIR/GPG-KEY"
press_enter_to_continue "When done, press Enter to write the ISO."
echo "writing the ISO..."
sh build/write_iso slint 1>>LOG_build_ISO 2>>LOG_build_ISO
echo "All done. You may now check then remove the file ./LOG_build_ISO"
