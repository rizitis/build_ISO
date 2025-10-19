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
[ "$(command -v slapt-get)" = "" ] && echo "Install slapt-get, then try again." && exit
[ "$(command -v spkg)" = "" ] && echo "Install spkg, then try again." && exit
# This directory should be owned by a regular user
[ "$REGULARUSER" = root ] && echo "Do not run this script in a directory owned by root!" && exit
. build/set_variables_slint
echo "We need to put 6G of files in this directory. if that's OK press Enter else press ctrl-C."
read -r
# In the file build/set_variables_slint, update the kernel version KVER and ISOVERSION if need be
echo "The kernel version is KVER=$KVER and the ISO VERSION ISOVERSION=$ISOVERSION as sourced from"
echo "./set_variables_slint. If they are up to date press Enter, else press ctrl-C and update them."
read -r
echo "Get the latest versions of scripts used during installation..."
sh build/get_scripts slint 1>>LOG_build_ISO 2>>LOG_build_ISO
echo
echo "Creating and populating the directory holding the packages,"
echo "from which the ISO will be written. This takes some time..."
sudo sh build/iso_dir slint |tee LOG_build_ISO
echo
echo "Check $ISODIR, if OK press Enter"
read -r
echo "Unpack Slackware's initramfs, customize it and put it into place..."
sudo sh build/initrd slint 1>>LOG_build_ISO 2>>LOG_build_ISO
echo "Check initramfs, if OK press Enter."
read -r
echo
echo "Adding the package's metadata. This takes a long time..."
sh build/metadata slint 1>>LOG_build_ISO
echo
echo "writing the ISO..."
sh build/write_iso slint 1>>LOG_build_ISO 2>>LOG_build_ISO
echo "All done. You may now check then remove the file ./LOG_build_ISO"
