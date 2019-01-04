#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Prepare the Installation
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

# Download ISO
http://ftp-stud.hs-esslingen.de/pub/Mirrors/archlinux/iso/latest/archlinux-*-x86_64.iso
http://ftp-stud.hs-esslingen.de/pub/Mirrors/archlinux/iso/latest/md5sums.txt
http://ftp-stud.hs-esslingen.de/pub/Mirrors/archlinux/iso/latest/sha1sums.txt

# validate Checksums
md5sum archlinux-*-x86_64.iso;
sha1sum archlinux-*-x86_64.iso

# Prepare USB-Stick
dd bs=4M if=archlinux-*-x86_64.iso of=/dev/sdX status=progress && sync;

# Deutsches Tastatur-Layout: de-latin1/de-latin1-nodeadkeys
loadkeys de-latin1;

bash;

# Packages vom USB-Stick aktualisieren
pacman -Sy;

# Zugriff für Remote-Installation: ssh root@IP
# VortualBox: Netzwerk-Typ muss auf "Netzwerkbrücke" stehen
systemctl start sshd;
passwd root;
ip -4 addr;

# pacman -S git;
# git clone https://github.com/tfreese/arch-install.git;
# chmod +x arch-install/*.sh;
# nano arch-install/archi-install.conf;
#
# read -rp "Press any key to pacstrap";
# TIME=$(date '+%Y%m%d_%H%M%S')
