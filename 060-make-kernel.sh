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

# HOOKS=(base udev autodetect modconf block mdadm keyboard keymap encrypt lvm2 filesystems fsck)
# HOOKS=(base systemd autodetect modconf block mdadm_udev keyboard sd-vconsole sd-encrypt sd-lvm2 filesystems fsck)
nano /etc/mkinitcpio.conf;

mkinitcpio -p linux;
