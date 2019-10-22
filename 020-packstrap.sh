#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Initial pacstrap and arch-chroot
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

# System-Partition mounten
# LVM
mount /dev/vghost/root /mnt;
# btrfs
mount -o subvol=root /dev/sda3 /mnt;
mkdir /mnt/home;
mount -o subvol=home /dev/sda3 /mnt/home;


# Boot-Partition mounten: UEFI / GRUP2 / SYSLINUX
mkdir /mnt/boot;
mount /dev/md0 /mnt/boot;

pacstrap /mnt base base-devel linux linux-headers linux-firmware nano efibootmgr dosfstools btrfs-progs;

genfstab -p /mnt >> /mnt/etc/fstab;

echo " " >> /mnt/etc/fstab;
echo "Swap-Prio: DEVICE     none  swap   defaults,pri=1   0 0" >> /mnt/etc/fstab;
echo "#Bei SSD fstab Eintrag ändern in" >> /mnt/etc/fstab;
echo "#/dev/ssd	/	ext4	defaults,noatime,discard	0	1" >> /mnt/etc/fstab;
echo "#HDD defaults,noatime,stripe=32" >> /mnt/etc/fstab;

arch-chroot /mnt;
