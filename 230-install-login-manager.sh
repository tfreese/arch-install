#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Login Manager
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


#############################################################################################################
# Wenn der Loginmanager disabled ist, muss dieser mit "startx" aufgerufen werden !
#############################################################################################################


#############################################################################################################
# SLIM
pacman --noconfirm --needed -S slim;
pacman --noconfirm --needed -S archlinux-themes-slim;

systemctl enable slim;
systemctl start slim; # Startet den Desktop


#############################################################################################################
#GDM = GNOME !!!
pacman --noconfirm --needed -S gdm;

systemctl enable gdm;
systemctl start gdm; # Startet den Desktop


#############################################################################################################
systemctl set-default graphical.target;
