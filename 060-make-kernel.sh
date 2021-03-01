#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Config and create Kernel
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

# Falls /boot auf einer FAT-Partition liegt (UEFI).
pacman --noconfirm --needed -S dosfstools; # vfat Treiber

# MODULES=(ext4)
#
# HOOKS=(base udev autodetect modconf block mdadm keyboard keymap lvm2 filesystems fsck)
# HOOKS=(base systemd autodetect modconf block mdadm_udev keyboard sd-vconsole lvm2 filesystems fsck)
#
# LVM on LUKS
# HOOKS=(base udev autodetect keyboard keymap modconf block mdadm encrypt lvm2 filesystems fsck)
# HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block mdadm_udev sd-encrypt lvm2 filesystems fsck)
nano /etc/mkinitcpio.conf;

mkinitcpio -p linux;
