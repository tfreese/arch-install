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

# /etc/slim.conf
# /usr/share/slim/themes
# Preview: slim -p /usr/share/slim/themes/.../

#############################################################################################################
# LXDM (für LXDE)
pacman --noconfirm --needed -S lxdm;

systemctl enable lxdm;
systemctl start lxdm; # Startet den Desktop

# /etc/lxdm/lxdm.conf

#############################################################################################################
# GDM = GNOME !!!
pacman --noconfirm --needed -S gdm;

systemctl enable gdm;
systemctl start gdm; # Startet den Desktop


#############################################################################################################
systemctl set-default graphical.target;
