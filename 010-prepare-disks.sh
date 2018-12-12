#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Prepare the Disks
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

# Partitionen löschen
parted /dev/sda rm 4;
parted /dev/sda rm 3;
parted /dev/sda rm 2;
parted /dev/sda rm 1;

# Filesystem bereinigen
mdadm --zero-superblock /dev/sda;
wipefs --all --force /dev/sda;

# Partition(en) anlegen
parted /dev/sda mklabel gpt;

# GRUB2
parted -a optimal /dev/sda mkpart primary 2048s 512MB; # for gpt for grub
parted -a optimal /dev/sda mkpart primary 512MB 250GB; # Windows
parted -a optimal /dev/sda mkpart primary 250GB 270GB; # swap/raid
parted -a optimal /dev/sda mkpart primary 270GB 100%;  # root/raid

parted /dev/sda set 1 bios_grub on;
parted /dev/sda set 3 raid on;
# parted /dev/sda set 3 swap on;
parted /dev/sda set 3 raid on;

#############################################################################################################
# Oder mit UEFI
#
# Prüfen, ob BIOS im UEFI Mode
efivar -l;
efibootmgr -v;
bootctl status;

# Verzeichnis muss vorhanden sein
ls /sys/firmware/efi;

# Devices ausgeben
lsblk -o NAME,LABEL,SIZE,FSTYPE,TYPE,MOUNTPOINT,MODEL,UUID;

parted -a optimal /dev/sdb mkpart ESP fat32 2048s 512MB; # efiboot
parted -a optimal /dev/sdb mkpart primary 512MB 32GB;    # swap/raid
parted -a optimal /dev/sdb mkpart primary 32G 4TB;       # root/raid

parted /dev/sdb print;

parted /dev/sdb set 1 esp on;
parted /dev/sdb set 2 raid on;
# parted /dev/sdb set 2 swap on;
parted /dev/sdb set 3 raid on;

parted /dev/sdb name 1 efiboot;
parted /dev/sdb name 2 swap;
parted /dev/sdb name 3 raid;

parted /dev/sdb print;

parted /dev/sdb align-check opt 1;
parted /dev/sdb align-check opt 2;
parted /dev/sdb align-check opt 3;

# Partitions-Tabellen kopieren ZIEL <- QUELLE
sgdisk -R /dev/sdc /dev/sdb;
sgdisk -R /dev/sdd /dev/sdb;

## UUIDS neu vergeben
sgdisk -G /dev/sdc;
sgdisk -G /dev/sdd;

parted /dev/sdc print;
parted /dev/sdd print;

# Raids erstellen
mdadm --create --verbose /dev/md0 --metadata 1.0    --raid-devices=3 --level=1 /dev/sd[bcd]1;
mdadm --create --verbose /dev/md1 --bitmap=internal --raid-devices=3 --level=1 /dev/sd[bcd]2;
mdadm --create --verbose /dev/md2 --bitmap=internal --raid-devices=3 --level=5 --chunk=64 /dev/sd[bcd]3;
#--force --assume-clean

# EFI Partion formatieren (FAT32)
mkfs.vfat -F 32 /dev/md0;

# SWAP erstellen
# parted /dev/md1 set 1 lvm on;
mkswap -f /dev/md1;
swapon /dev/md1;

# Oder SWAP ohne Raid mit Kernel-Striping
mkswap -f /dev/sda2;
mkswap -f /dev/sdb2;
mkswap -f /dev/sdc2;
swapon -p 1 /dev/sda2;
swapon -p 1 /dev/sdb2;
swapon -p 1 /dev/sdc2;
#echo "DEVICE     none  swap   defaults,pri=1   0 0" >> /mnt/etc/fstab;

# LVM erstellen
parted /dev/md2 set 1 lvm on;

pvcreate -v --dataalignment 64k /dev/md2;
vgcreate -v --dataalignment 64k vghost /dev/md2;

lvcreate -v --wipesignatures y -L 64G -n root vghost;
lvcreate -v --wipesignatures y -L 64G -n home vghost;
lvcreate -v --wipesignatures y -L 16G -n opt vghost;

# System Partionen formatieren.
mkfs.ext4 -v -m 1 -b 4096 -E stride=16,stripe-width=32 -L root /dev/vghost/root;
mkfs.ext4 -v -m 1 -b 4096 -E stride=16,stripe-width=32 -L root /dev/vghost/home;
mkfs.ext4 -v -m 0 -b 4096 -E stride=16,stripe-width=32 -L opt /dev/vghost/opt;

# Anpassen für Raid-Optionen
# tune2fs -E stride=16,stripe-width=32 /dev/xxx;
#
# http://busybox.net/~aldot/mkfs_stride.html
# block size (file system block size) = 4096
# stripe-size (raid chunk size) = 64k
# stride = stripe-size / block size =  64k / 4k = 16
# stripe-width: stride * #-of-data-disks (3 disks RAID5 = 2 data disks) = 16 * 2 = 32

# Prüfung nach n mounts
tune2fs -c 30 /dev/vghost/root;
tune2fs -c 30 /dev/vghost/home;
tune2fs -c 30 /dev/vghost/opt;
