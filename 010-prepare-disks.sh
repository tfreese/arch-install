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

#############################################################################################################
# Prüfen, ob BIOS im UEFI Mode
efivar -l;
efibootmgr -v;
bootctl status;

# Verzeichnis muss vorhanden sein
ls /sys/firmware/efi;

# Devices ausgeben
lsblk -o NAME,LABEL,SIZE,FSTYPE,TYPE,MOUNTPOINT,MODEL,UUID;

#############################################################################################################
# Filesystem bereinigen
mdadm --zero-superblock /dev/sda[123];
wipefs --all --force /dev/sda[123];

# MBR + Partitions-Tabelle + Signatur löschen
dd if=/dev/zero of=/dev/sdX bs=512 count=1;

# Partitionen löschen
parted /dev/sda rm 3;
parted /dev/sda rm 2;
parted /dev/sda rm 1;

# partprobe

# Partitionen anlegen
parted /dev/sda mklabel gpt;

# Boot-Partitionen
parted -a optimal /dev/sda mkpart primary   2048s 2M;   # grub boot     / raid1
parted -a optimal /dev/sda mkpart primary   2048s 512M; # syslinux boot / raid1
parted -a optimal /dev/sda mkpart ESP fat32 2048s 512M; # uefi boot     / raid1

# Raid-Partitionen
parted -a optimal /dev/sda mkpart primary   512M  16G;   # swap / raid1
parted -a optimal /dev/sda mkpart primary   16G   500G;  # lvm  / raid1
parted -a optimal /dev/sda mkpart primary   500G  4000G; # btrfs

parted /dev/sda set 1 bios_grub on; # GRUB2 Boot-Flag
parted /dev/sda set 1 boot      on; # SYSLINUX Boot-Flag
parted /dev/sda set 1 esp       on; # UEFI Boot-Flag
parted /dev/sda set 2 raid on;
# parted /dev/sda set 2 swap on;
parted /dev/sda set 3 raid on;

#############################################################################################################
parted /dev/sda name 1 boot;
parted /dev/sda name 2 swap;
parted /dev/sda name 3 lvm;
parted /dev/sda name 4 data;

parted /dev/sda print free;

parted /dev/sda align-check opt 1;
parted /dev/sda align-check opt 2;
parted /dev/sda align-check opt 3;
parted /dev/sda align-check opt 4;

# Partitions-Tabellen kopieren ZIEL <- QUELLE
sgdisk -R /dev/sdb /dev/sda;
sgdisk -R /dev/sdc /dev/sda;

## UUIDS neu vergeben
sgdisk -G /dev/sdb;
sgdisk -G /dev/sdc;

parted /dev/sdb print free;
parted /dev/sdc print free;

# Raids erstellen
mdadm --create --verbose /dev/md0 --bitmap=internal --raid-devices=3 --level=1 --metadata 1.0            --name=host:boot /dev/sd[abc]1;
mdadm --create --verbose /dev/md1 --bitmap=internal --raid-devices=3 --level=1                           --name=host:swap /dev/sd[abc]2;
mdadm --create --verbose /dev/md2 --bitmap=internal --raid-devices=3 --level=5 --chunk=64 --assume-clean --name=host:lvm  /dev/sd[abc]3;
mdadm --create --verbose /dev/md3 --bitmap=internal --raid-devices=3 --level=1                           --name=host:data /dev/sd[abc]4;
#--force

# BOOT Partion formatieren (FAT32): benötigt dosfstools
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
#echo "SSD	none	swap	defaults,discard,nofail,pri=100		0 0" >> /mnt/etc/fstab;
#echo "HDD	none	swap	defaults,nofail,pri=10				0 0" >> /mnt/etc/fstab;

# Verschlüsselung
cryptsetup benchmark;

dd if=/dev/urandom of=/dev/md2 bs=4096 status=progress;
cryptsetup luksFormat --verbose --verify-passphrase --key-size 512 --hash sha512 --use-random --cipher aes-xts-plain64 /dev/md2;
cryptsetup luksOpen /dev/md2 crypt_lvm;
pvcreate -v --dataalignment 64k /dev/mapper/crypt_lvm;
vgcreate -v --dataalignment 64k vghost /dev/mapper/crypt_lvm;

# btrfs
mkfs.btrfs -L NAME -d raid1 -m raid1 /dev/sda4 /dev/sdb4 /dev/sdc4;

# Meta-Daten doppelt ablegen bei einer einzelnen Disk (nicht bei SSD verwenden!).
mkfs.btrfs -L pool-NAME -m dup /dev/md3;

mkdir /pool;
mount /dev/md3 /pool;
cd /pool;
btrfs subvolume create root;
btrfs subvolume create home;

# LVM erstellen
# parted /dev/md2 set 1 lvm on;

pvcreate -v --dataalignment 64k /dev/md2;
vgcreate -v --dataalignment 64k vghost /dev/md2;

lvcreate -v --wipesignatures y -L 32G -n root vghost;

# System Partionen formatieren.
mkfs.ext4 -v -m 1 -b 4096 -E stride=16,stripe-width=32 -L root /dev/vghost/root;

# Anpassen für Raid-Optionen
# tune2fs -E stride=16,stripe-width=32 /dev/xxx;
#
# Beispiel in /ets/fstab:
# /dev/vghost/root	/	ext4 rw,relatime,stripe=32	0	1
#
# http://busybox.net/~aldot/mkfs_stride.html
# block size (file system block size) = 4096
# stripe-size (raid chunk size) = 64k
# stride = stripe-size / block size =  64k / 4k = 16
# stripe-width: stride * #-of-data-disks (3 disks RAID5 = 2 data disks) = 16 * 2 = 32

# Prüfung nach n mounts
tune2fs -c 30 /dev/vghost/root;
