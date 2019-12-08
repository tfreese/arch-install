#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Bluetooth
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


pacman --noconfirm --needed -S blueberry;
pacman --noconfirm --needed -S bluez;
pacman --noconfirm --needed -S bluez-libs;
pacman --noconfirm --needed -S bluez-utils;
pacman --noconfirm --needed -S bluez-firmware;
pacman --noconfirm --needed -S pulseaudio-bluetooth;


sed -i 's/'#AutoEnable=false'/'AutoEnable=true'/g' /etc/bluetooth/main.conf


systemctl enable bluetooth.service;
systemctl start bluetooth.service;
systemctl status bluetooth.service;
