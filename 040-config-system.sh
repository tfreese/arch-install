#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Config the System
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


pacman --noconfirm --needed -S sudo;
pacman --noconfirm --needed -S bash-completion;
pacman --noconfirm --needed -S mdadm;
pacman --noconfirm --needed -S lvm2;

pacman --noconfirm --needed -S intel-ucode; #Firmware Bug: TSC_DEADLINE, behebt microcode Warnung beim Booten
pacman --noconfirm --needed -S parted;
pacman --noconfirm --needed -S gptfdisk;
pacman --noconfirm --needed -S dosfstools; # vfat Treiber
pacman --noconfirm --needed -S ntfs-3g; # ntfs Treiber
pacman --noconfirm --needed -S rrdtool;
pacman --noconfirm --needed -S bc; # Bash Arithmetik


HOSTNAME="host";
DOMAIN="fritz.box";
NAMESERVER="192.168.1.1";

#loadkeys de-latin1;
echo "$HOSTNAME" > /etc/hostname;
echo "domain $DOMAIN" > /etc/resolv.conf;
echo "nameserver $NAMESERVER" >> /etc/resolv.conf;

echo "LANG=de_DE.UTF-8" > /etc/locale.conf;
echo "LC_COLLATE=C" >> /etc/locale.conf;
echo "LANGUAGE=de_DE" >> /etc/locale.conf

echo "KEYMAP=de-latin1" > /etc/vconsole.conf;
echo "FONT=lat9w-16" >> /etc/vconsole.conf
echo "FONT_MAP=8859-1_to_uni" >>/etc/vconsole.conf

ln -sfn /usr/share/zoneinfo/Europe/Berlin /etc/localtime;

#echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen;
#echo "de_DE ISO-8859-1" >> /etc/locale.gen;
#echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen;
sed -i_"$TIME" 's/^#de_DE/de_DE/g' /etc/locale.gen;

locale-gen;

systemctl enable dhcpcd;

# Raid speichern
mdadm --detail --scan >> /etc/mdadm/mdadm.conf;
