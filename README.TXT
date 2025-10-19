For the impatients, to build a Slint ISO, do this:

1. (Create if need be then) cd to a directory owned by a regular user, here
   named /data (but it can also be $HOME or one of its subdirs)
2. type as regular user:
   git clone https://github.com/DidierSpaier/build_ISO
   cd build_ISO
   sh build_Slint_ISO.sh
   The ISO image should then be available in /data/build_ISO or such.
   We will name this directory $SLINTROOT

Before you begin, there are a few requirements:
- At least 6G of space on disk should be available
- The host should be a 64bit Linux system
- The packages slapt-get and spkg should be installed.
  slapt-get is installed by default in Salix, Slackel and Slint.
  For Slackware et derivatives, a SlackBuild is available in
  https://slackbuilds.org  and she upstream repository is
  https://github.com/jaos/slapt-get/
  spkg is installed by default in Salix and Slint. The upstream repository is
  https://github.com/gapan/spkg
- Are also needed the usual POSIX/Linux utilities, git and a good enough
  Internet link to clone and fetch packages from remote repositories.
- The signature CHECKSUMS.md5.gz.ass at the root of the ISO should be created
  by providing a passphrase when asked and the associated GPG_KEY stored
  somewhere to allow verification, like in the directory storing the ISO.
- sudo should be configured.

We describe below the process of building an ISO to install Slint, performed
running the shell script build_Slint_ISO.sh whose we list the steps.

NOTE: initially the process also allowed to build an ISO able to install
Salix or Slackware. This attracted few interest so for now the script
can only build an ISO to install Slint version 15.0.

All scripts mentioned below are sourced or run by build_Slint_ISO.sh.
- The script checks or advise the user to check some requirements.
- build/set_variables_slint is sourced to set the variables used during the
  building process, like the ones mentioned here. Edit this file as need be.
- buikd/get_scripts gets the latest versions of scripts that will run during
  installation of the system thus should be included in the ISO.
- buikd/iso_dir fetches from remote repositories then moves in $ISODIR/slint
  that it creates the packages to be included in the then copies in
  $ISODIR/boot/grub the file grub.cfg. It also writes a few files in $ISODIR,
  including a linux kernel.
- metadata writes in $ISODIR/slint the metadata associated to the packages and
  the global metadata in $ISODIR, then asks the user to type the passphrase
  associated to their GPG key to sign the file CHECKSUMS.md5.gz.
- initrd unpacks the file initrd.img fetched from
  https://slackware.uk/slackware/slackware64-15.0/EFI/BOOT in ./initrd-tree,
  then adds to it files and packages needed to make the installer accessible
  with braille and speech and polyglot and manage installation, then writes
  $ISODIR/initrd.
- write_iso writes the ISO image in $ROOTDIR

Note: bear in mind while reading the following that for now we put on hold the
ability to build an ISO allowing to install Salix or Slackware,

Customizing the ISO and the installer for $distribution is done mainly by two
scripts sourcing the file ./build/set_variables_$distribution that sets
variables among which $SETS, list of sets of packages to install in
$distribution stored in ./sets.

- iso_dir stores in $ISODIR/slint the packages sets to install, listed in
  $SETS for $distribution, and those, listed in ./sets/addonintsaller, that
  will be added to the initramfs by /sbin/rc.S after having started it. For
  Slint it adds the packages that will be installed if the locale if their
  name fits the one selected by the user.
- initrd adds to the installer:
  . the packages and files used to make it polyglot, accessible with speech
    and braille, including a package installer-translations-${distribution}
    built from po files adapted to $distribution,
  . the lists of packages to install depending on the distribution, stored in
    ./sets,
  . the installation scripts /etc/rc.d/rc.S, /sbin/functions and /sbin/start,
     the latter adapted to the distribution, copying
     ./misc/start"$distribution" as /sbin/start, and the file
    /slapt-getrc.installation$distribution.

Installation is customized for $distribution:
- through specific settings in /sbin/start:
  . $distribution set in /tmp/distro,
  . the list of sets of packages to install set in /tmp/set/,
  . a sed command replacing in /sbin/functions and /etc/rc.d/rc.d Slint by
    Salix or Slackware as needed to display the installer's messages
    accordingly.
  . a specific postconfigure$(cat /tmp/distro) function called by /sbin/start
- using the "-c /slapt-getrc.installation$distribution" as configuration file
  for slapt-getrc.

Packages' installation process:
1. The script /etc/rc.d/rc.S (adapted from Slackware's installer) is started
   by init. After having enabled swap in zram to increase the usable RAM, it
   adds to the initramfs packages needed during installation.
2. The script /sbin/start (customized for each distribution), started by the
   user typing start, does some distribution specific settings, then calls
   functions of /sbin/functions.
3. The packages are installed in the target system by functions of
   /sbin/functions in the following  order, after having mounted its root
   filesystem as /SLINT regardless of the distribution:
   - the package aaa_base, fetched from $ISO/slint
   - the packages listed in /sets/bootstrap$distribution, fetched from
     $ISO/slint
   - the remaining sets of packages to install, fetched from a remote
     repository if possible (to provide their current versions), else from
     $ISO/slint. These sets are:
     . For Slint, the set fullslint and the sets i3 and/or lxqt and/or mate as chosen by the user
       (function selectcontent)
     . For other distributions, all sets listed in /tmp/set and not yet installed

Some Slint packages are also installed in other distributions to bring them
additional features, or to provide more recent packages than those provided in
the other distributions. They are listed in the set slint$distribution.
