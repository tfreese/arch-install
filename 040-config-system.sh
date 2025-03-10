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
pacman --noconfirm --needed -S btrfs-progs;
pacman --noconfirm --needed -S logrotate;

pacman --noconfirm --needed -S parted;
pacman --noconfirm --needed -S gptfdisk;
pacman --noconfirm --needed -S dosfstools;
pacman --noconfirm --needed -S ntfs-3g;


#loadkeys de-latin1;
echo "HOST" > /etc/hostname;

# Bei Verwendung von systemd-resolved.service:
# /etc/systemd/resolved.conf anpassen
# mv /etc/resolv.conf /etc/resolv.conf.bak # Create a backup
# ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

echo "LANG=de_DE.UTF-8" > /etc/locale.conf;
echo "LC_COLLATE=C" >> /etc/locale.conf;
echo "LANGUAGE=de_DE" >> /etc/locale.conf

echo "KEYMAP=de-latin1" > /etc/vconsole.conf;
echo "FONT=lat9w-16" >> /etc/vconsole.conf;
echo "FONT_MAP=8859-1_to_uni" >>/etc/vconsole.conf;

ln -sfn /usr/share/zoneinfo/Europe/Berlin /etc/localtime;

#echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen;
#echo "de_DE ISO-8859-1" >> /etc/locale.gen;
#echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen;
sed -i_"$TIME" 's/^#de_DE/de_DE/g' /etc/locale.gen;

locale-gen;

pacman --noconfirm --needed -S dhcpcd;
systemctl enable dhcpcd;

# Raid speichern
mdadm --detail --scan >> /etc/mdadm.conf;
