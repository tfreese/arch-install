#!/bin/bash
#
# Thomas Freese
#
# archlinux Installation-Script for my Desktop PC.
# https://wiki.archlinux.de/title/Anleitung_für_Einsteiger
#
# loadkeys [de-latin1/de-latin1-nodeadkeys];
# bash;
# pacman -Sy;
# pacman -S git;
# git clone https://github.com/tfreese/arch-install.git;
# chmod +x arch-install/*.sh;
# nano arch-install/archi-install.conf;
#
#

set -euo pipefail
# –x für debug

. "$(dirname "$0")"/functions.sh

################################################################################
# Settings
HOSTNAME="host";
GRUB_DEVICE="/dev/sda";

GROUP_ID="1000";
GROUP_NAME="test";
USER_ID="1000";
USER_NAME="test";

DOMAIN="..."
NETWORK="192.168.250.0";
GATEWAY="192.168.250.1";
BROADCAST="192.168.250.255";
IP="192.168.250.100";

WLAN_SSID="";
WLAN_PASSWORD="";

################################################################################
deletePartitions()
{
parted /dev/sda rm 4;
parted /dev/sda rm 3;
parted /dev/sda rm 2;
parted /dev/sda rm 1;
}

################################################################################
createPartitions()
{
# Filesystem bereinigen.
mdadm --zero-superblock /dev/sda;
wipefs --all --force /dev/sda;

# Partition(en) anlegen.
parted /dev/sda mklabel gpt;

# For VM-Test
parted -a optimal /dev/sda mkpart primary 2048s 2MB;    # for gpt for grub
parted -a optimal /dev/sda mkpart primary 2MB 1GB;      # Windows
parted -a optimal /dev/sda mkpart primary 1GB 5GB;      # swap
parted -a optimal /dev/sda mkpart primary 5GB 100%;     # root

#parted -a optimal /dev/sda mkpart primary 2048s 2MB;   # for gpt for grub
#parted -a optimal /dev/sda mkpart primary 2MB 250GB;   # Windows
#parted -a optimal /dev/sda mkpart primary 250GB 270GB; # swap
#parted -a optimal /dev/sda mkpart primary 270GB 100%;  # root

parted /dev/sda set 1 bios_grub on;
#parted /dev/sda set 3 swap on;

parted /dev/sda name 1 boot;
parted /dev/sda name 2 windows;
parted /dev/sda name 3 swap;
parted /dev/sda name 4 root;

parted /dev/sda print;

parted /dev/sda align-check opt 1;
parted /dev/sda align-check opt 2;
parted /dev/sda align-check opt 3;
parted /dev/sda align-check opt 4;
}

################################################################################
formatAndMountPartitions()
{
# pvcreate -v /dev/sda3:
# vgcreate -v vghost /dev/sda3:
# lvcreate -v -L 16G -n swap vghost;
# lvcreate -v -l 100%free -n root vghost;
# mkswap -f /dev/vghost/swap;
# swapon -p 1 /dev/vghost/swap;
# mkfs.ext4 -v -m 1 -b 4096 -L root /dev/vghost/root;
# mount -t ext4 /dev/vghost/root /mnt;

echo "";
read -rp "Press any key to create swap";
mkswap -f /dev/sda3;
swapon -p 1 /dev/sda3;

echo "";
read -rp "Press any key to format root partition";
mkfs.ext4 -v -m 1 -b 4096 -L root /dev/sda4;
mount -t ext4 /dev/sda4 /mnt;
}

################################################################################
reboot()
{
echo "";
echo "reboot pc: exit && umount -R /mnt && reboot";
read -rp "Press any key...";
}

################################################################################
# Before arch-chroot

#pacman --noconfirm -S parted;
#deletePartitions;
#createPartitions;
#formatAndMountPartitions;
#pacstrap;

################################################################################
# After arch-chroot

#installBasics
#configBasics "$HOSTNAME" "$GATEWAY";
#configRoot
#makeKernel;
#installGrub "$GRUB_DEVICE";
#reboot;

################################################################################
# After reboot

#createUser "$GROUP_ID" "$GROUP_NAME" "$USER_ID" "$USER_NAME";
#installSSH "$IP" "$USER_NAME";
#installCronie;
#installACPID;
#installTimesyncd;
#installRsync "$NETWORK";
#installRsnapshot;
#configNetwork "etho0" "$NETWORK" "$IP" "$BROADCAST" "$GATEWAY" "10";
#configNetwork "wlan0" "$NETWORK" "$IP" "$BROADCAST" "$GATEWAY" "20" "$WLAN_SSID" "$WLAN_PASSWORD";
#configIptables
#configServices;
#installConsoleBasics;
#systemctl daemon-reload;

################################################################################
# For Desktop

#installXServer;
#installKeyboard;
#installGraphicDriver;
#installLoginmanager;
#installCinnamon;
#installAudio;
#installCodecs;
#installDesktopBasics;
