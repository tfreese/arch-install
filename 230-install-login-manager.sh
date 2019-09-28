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
# LightDM
pacman --noconfirm --needed -S lightdm lightdm-gtk-greeter;
pacman --noconfirm --needed -S xorg-server-xephyr;

systemctl enable lightdm;
systemctl start lightdm;

# /etc/lightdm/lightdm.conf
allow-guest=false
 
[Seat:*]
greeter-session=lightdm-gtk-greeter
allow-guest=false

# /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
active-monitor=0
# background=/usr/share/backgrounds/xfce/CleanBlue.jpg			# xface
# background=/usr/share/backgrounds/gnome/adwaita-night.jpg		# cinnamon

# lightdm --test-mode –debug [-c /etc/lightdm/lightdm.conf]

#############################################################################################################
# SLIM
pacman --noconfirm --needed -S slim;
pacman --noconfirm --needed -S archlinux-themes-slim;

systemctl enable slim;
systemctl start slim;

# /etc/slim.conf
# /usr/share/slim/themes
# Preview: slim -p /usr/share/slim/themes/.../

#############################################################################################################
# LXDM (für LXDE)
pacman --noconfirm --needed -S lxdm;

systemctl enable lxdm;
systemctl start lxdm;

# /etc/lxdm/lxdm.conf

#############################################################################################################
# GDM = GNOME !!!
pacman --noconfirm --needed -S gdm;

systemctl enable gdm;
systemctl start gdm;


#############################################################################################################
systemctl set-default graphical.target;
