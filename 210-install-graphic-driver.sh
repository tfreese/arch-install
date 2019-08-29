#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Graphic Driver
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


#pacman –Ss | grep xf86-video;
#echo "select the right driver based on the following output:";
#lspci -k | grep VGA;

# Proprietärer Treiber: http://www.nvidia.com/object/unix.html
#pacman –Ss | grep nvidia;

pacman --noconfirm --needed -S nvidia;
pacman --noconfirm --needed -S nvidia-utils;
pacman --noconfirm --needed -S nvidia-settings;
# Anschliessend nach dem GUI-Start 'sudo nvidia-xconfig' ausführen.

#Für Hardware-Decoding (VDPAU):
pacman --noconfirm --needed -S libva-vdpau-driver;

# glxinfo, glxgears
pacman --noconfirm --needed -S mesa-demos;

# Für alte Hardware:
pacman --noconfirm --needed -S mesa xf86-video-fbdev xf86-video-vesa xorg-drivers;

# all drivers
#pacman --noconfirm --needed -S xf86-video-vesa;
#pacman --noconfirm --needed -S xorg-drivers;
#pacman --noconfirm --needed -S xf86-video-nv;
#pacman --noconfirm --needed -S nvidia-libgl;
#pacman --noconfirm --needed -S opencl-nvidia;
