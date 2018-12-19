#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the XServer
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


pacman --noconfirm --needed -S xorg-server;
pacman --noconfirm --needed -S xorg-xinit;
#pacman --noconfirm --needed -S xorg-utils;
#pacman --noconfirm --needed -S xorg-server-utils;
#pacman --noconfirm --needed -S xorg-twm;
pacman --noconfirm --needed -S xorg-xclock;
pacman --noconfirm --needed -S xterm;
pacman --noconfirm --needed -S ttf-dejavu;;

# For Laptops with Touchfield
#pacman --noconfirm --needed -S xf86-input-synaptics;
