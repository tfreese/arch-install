#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Desktop Manager
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
# Cinnamon
pacman --noconfirm --needed -S cinnamon;
pacman --noconfirm --needed -S nemo nemo-fileroller;
pacman --noconfirm --needed -S faenza-icon-theme;
pacman --noconfirm --needed -S numix-gtk-theme;
pacman --noconfirm --needed -S gnome-keyring libgnome-keyring;
pacman --noconfirm --needed -S gnome-screenshot;

# AUR cinnamon-sound-effects
# AUR mint-sounds

cp /etc/X11/xinit/xinitrc ~/.xinitrc;

# Andere Zeilen mit "twm, xclock, xterm und exec" auskommentieren.
echo "exec cinnamon-session" >> ~/.xinitrc;


#############################################################################################################
# Mate
pacman --noconfirm --needed -S mate;
pacman --noconfirm --needed -S mate-extra;

cp /etc/X11/xinit/xinitrc ~/.xinitrc;

# Andere Zeilen mit "twm, xclock, xterm und exec" auskommentieren.
echo "exec mate-session" >> ~/.xinitrc;


#############################################################################################################
# GNOME
pacman --noconfirm --needed -S gnome;
pacman --noconfirm --needed -S gnome-extra;

cp /etc/X11/xinit/xinitrc ~/.xinitrc;

# Andere Zeilen mit "twm, xclock, xterm und exec" auskommentieren.
echo "exec gnome-session" >> ~/.xinitrc;


#############################################################################################################
# XFCE
pacman --noconfirm --needed -S xfce4;
pacman --noconfirm --needed -S xfce4-goodies;
pacman --noconfirm --needed -S human-icon-theme;
pacman --noconfirm --needed -S pavucontrol;

cp /etc/X11/xinit/xinitrc ~/.xinitrc;

# Andere Zeilen mit "twm, xclock, xterm und exec" auskommentieren.
echo "exec startxfce4" >> ~/.xinitrc;


#############################################################################################################
# LXDE
pacman --noconfirm --needed -S lxde [gamin dbus hal];

cp /etc/X11/xinit/xinitrc ~/.xinitrc;

# Andere Zeilen mit "twm, xclock, xterm und exec" auskommentieren.
echo "exec startlxde" >> ~/.xinitrc;

# Nun muss hal noch bei den Daemons in der /etc/rc.conf eingetragen werden:
# DAEMONS=(... hal ...)
