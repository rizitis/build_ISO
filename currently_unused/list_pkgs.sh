

CWD=$(pwd)
MIRROR=rsync://slackware.uk
TARGET=/data
VERSION=15.0
BUILDSCRIPTS=/repo/x86_64/slint-15.0/source/build_ISO
rsync -rlpt --delete -P -H "$MIRROR"/salix/x86_64/slackware-"$VERSION" "$TARGET"
( cd "$BUILDSCRIPTS"
sh "$BUILDSCRIPTS/build_lists_of_packages.sh"
)
DATESTAMP="$(date +%Y%m%d)"
LISTS="$BUILDSCRIPTS/pkg_lists/$DATESTAMP"
# We extract from /var/slapt-get/package_data the remote paths to and priority of packages available
# in a remote directory based on slapt-getrc.
# We put in the same line the package's name, mirror, priority and location.
# if 
store in one line 
 and format the list like this
# full path|priority
# with full path=PACKAGE MIRRORPACKAGE LOCATIONPACKAGE NAME|PACKAGE PRIORITY

# 
# package name|package short name|version|size uncompressed (unit: in K bytes)|short description  
# Example of a package's record:

PACKAGE NAME:  BeautifulSoup4-1-noarch-1slint.txz
PACKAGE MIRROR:  https://slackware.uk/slint/x86_64/slint-15.0/
PACKAGE PRIORITY:  4
PACKAGE LOCATION:  ./slint
PACKAGE SIZE (compressed):  0 K
PACKAGE SIZE (uncompressed):  0 K
PACKAGE REQUIRED:   python-beautifulsoup4
PACKAGE CONFLICTS:   
PACKAGE SUGGESTS:   
PACKAGE MD5SUM:  2f12015efda561e1da185a9ab92daf40
PACKAGE DESCRIPTION:
BeautifulSoup4: BeautifulSoup4 (alias python-beautifulsoup4)
BeautifulSoup4: 
BeautifulSoup4: This is just a metapackage for installing python-beautifulsoup4
BeautifulSoup4: It is useful when other packages are looking for a
BeautifulSoup4: "BeautifulSoup4" package as a dependency.
BeautifulSoup4: 
BeautifulSoup4: 
BeautifulSoup4: 
BeautifulSoup4: 
BeautifulSoup4: 
BeautifulSoup4: 




# PACKAGE NAME:  apr-1.7.2-x86_64-1_slack15.0.txz
# PACKAGE LOCATION:  ./patches/packages
# PACKAGE SIZE (compressed):  260 K
# PACKAGE SIZE (uncompressed):  1240 K
# PACKAGE REQUIRED:  util-linux
# PACKAGE CONFLICTS:  
# PACKAGE SUGGESTS:  
# PACKAGE DESCRIPTION:
# apr: apr (Apache Portable Runtime)
# apr:
# apr: The mission of the Apache Portable Runtime (APR) is to provide a
# apr: free library of C data structures and routines, forming a system
# apr: portability layer to as many operating systems as possible.
# apr:


sed -n '
/PACKAGE NAME/{
# keep only the full name of the package, like "apr-1.7.2-x86_64-1_slack15.0.txz"
s/.* //
insert a "|" after the package full name
s/.*/&|/
# Replace the contents of the hold space with the contents of the pattern space.
h
# Get the package short name and its version, like "apr-1.7.2"
s/-[^-]*-[^-]*$//
# Surround the package short name by "|" characters
s/-[^-]*$/|&|/
# Remove the character "-" before the package version
s/|-/|/
# Append the next line which begins with "# PACKAGE LOCATION" to the current one
N
# Remove the "/n" before the first and the second lines
s/\n//
# Keep only the package location
s@PACKAGE LOCATION.*/@@
# Append the next line which begins with # PACKAGE SIZE (compressed)to the current one.
N
# Remove the appended line and append a character "|" after the package location.
s/\n.*/|/
# In this example the location becomes "packages" but we want it to be "patches"
s/packages|$/patches|/
# Append the next line beginning with "# PACKAGE SIZE (uncompressed)" to the current one.
N
# Remove the character "\n" between the lines.
s/\n//
# Keep only the package size uncompressed
s/PACKAGE SIZE (uncompressed):  //
# Remove the last two characters like " K" from the line but append a "|" character
s/..$/|/
# Append each of the four next lines to the current then remove it.
N
s/\n.*//
N
s/\n.*//
N
s/\n.*//
N
s/\n.*//
# Append the first line of the package description (its short description) to the current one
N
# Remove the characters from "\n" to the opening parenthesis of the short description.
s/\n.*[(]//
# Remove the closing parenthesis from the short description. 
s/[)]$//
# Append to the hold space a <newline> followed by the contents of the pattern space.
H
# Replace the contents of the pattern space by the contents of the hold space.
g
# Remove the character "\n" between the lines
s/\n//
# print the line.
p
}
' /data/slackware-15.0/PACKAGES.TXT \
/data/slackware-15.0/patches/PACKAGES.TXT \
/repo/x86_64/slint-15.0/PACKAGES.TXT |sort > allpackages
# We keep only the lines matching a package name listed in $LISTS/PACKAGES i.e. packages that would
# be included in a just built ISO.
sed 's@.*/@@' $LISTS/PACKAGES_WITH_EXTRA |sort > included
rm -f packages
while read pkg; do
	grep "^$pkg" allpackages >> packages
done < included

sed 's/\([^|]*\)|.*/\1/' packages > packagesnames
(
cd /var/lib/pkgtools/packages
rm -f allbinaries 
ls -1 |while read -r i; do
# We only categorize software containing an executable intended to run by the user
	icommands=$(sed -n '\@usr/bin/.@s@.*/@@p' ${i%.txz})
	if [ "$icommands" ]; then
	ishort=$(echo $i|sed 's/-[^-]*-[^-]*-[^-]*$'//)
	idesc=$(sed -n "6{s/.*[(]//;s/[)]//p}" $i)
		echo "${i%.txz} | $ishort | $idesc | $icommands"|paste -s -d' ' >>$CWD/allbinaries
	fi
done
)
