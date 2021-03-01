#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Use all Cores
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

pacman --noconfirm --needed -S pigz; # parallel gzip

# /tmp muss dann mit 'noexec' gemountet werden zur Sicherheit.
# Dies Kollidiert dann aber mit einigen anderen Anwendungen.
# sed -i 's/#BUILDDIR=/tmp/makepkg/BUILDDIR=/tmp/makepkg/g' /etc/makepkg.conf

numberOfCores=$(grep -c ^processor /proc/cpuinfo);

case $numberOfCores in
	32)
		sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j33"/g' /etc/makepkg.conf
		sed -i 's/COMPRESSGZ=(gzip -c -f -n)/COMPRESSGZ=(pigz -p 32 -c -f -n)/g' /etc/makepkg.conf
		sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -T 32 -c -z -)/g' /etc/makepkg.conf
		;;
	24)
		sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j25"/g' /etc/makepkg.conf
		sed -i 's/COMPRESSGZ=(gzip -c -f -n)/COMPRESSGZ=(pigz -p 24 -c -f -n)/g' /etc/makepkg.conf
		sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -T 24 -c -z -)/g' /etc/makepkg.conf
		;;
	16)
		sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j17"/g' /etc/makepkg.conf
		sed -i 's/COMPRESSGZ=(gzip -c -f -n)/COMPRESSGZ=(pigz -p 16 -c -f -n)/g' /etc/makepkg.conf
		sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -T 16 -c -z -)/g' /etc/makepkg.conf
		;;
	8)
		sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j9"/g' /etc/makepkg.conf
		sed -i 's/COMPRESSGZ=(gzip -c -f -n)/COMPRESSGZ=(pigz -p 8 -c -f -n)/g' /etc/makepkg.conf
		sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -T 8 -c -z -)/g' /etc/makepkg.conf
		;;
	6)
		sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j7"/g' /etc/makepkg.conf
		sed -i 's/COMPRESSGZ=(gzip -c -f -n)/COMPRESSGZ=(pigz -p 6 -c -f -n)/g' /etc/makepkg.conf
		sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -T 6 -c -z -)/g' /etc/makepkg.conf
		;;
	4)
		sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j5"/g' /etc/makepkg.conf
		sed -i 's/COMPRESSGZ=(gzip -c -f -n)/COMPRESSGZ=(pigz -p 4 -c -f -n)/g' /etc/makepkg.conf
		sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -T 4 -c -z -)/g' /etc/makepkg.conf
		;;
	2)
		sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j3"/g' /etc/makepkg.conf
		sed -i 's/COMPRESSGZ=(gzip -c -f -n)/COMPRESSGZ=(pigz -p 2 -c -f -n)/g' /etc/makepkg.conf
		sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -T 2 -c -z -)/g' /etc/makepkg.conf
		;;
	*)
		echo "We do not know how many cores you have."
		echo "Do it manually."
		;;
esac
