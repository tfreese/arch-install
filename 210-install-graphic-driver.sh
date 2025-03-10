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

# DRI Treiber für 3D Beschleunigung
pacman --noconfirm --needed -S mesa mesa-vdpau;
# glxinfo, glxgears
pacman --noconfirm --needed -S mesa-demos;

#Für Hardware-Decoding (VDPAU):
pacman --noconfirm --needed -S libva-utils libva-vdpau-driver;

# Proprietärer Treiber: http://www.nvidia.com/object/unix.html
#pacman –Ss | grep nvidia;

# NVIDIA
pacman --noconfirm --needed -S nvidia nvidia-utils nvidia-settings;
# Anschliessend nach dem GUI-Start 'sudo nvidia-xconfig' ausführen.

# RADEON
pacman --noconfirm --needed -S xf86-video-amdgpu vulkan-radeon;

# Einstellungen per Console
# xrandr --output DP-4 --mode 2560x1440 --rate 144;
# xrandr --output DP-4 --mode 2560x1440 --rate 144 --primary --output DP-0 --mode 2560x1440 --rate 144 --right-of DP-4
pacman --noconfirm --needed -S xorg-xrandr;

# Für alte Hardware:
pacman --noconfirm --needed -S xf86-video-fbdev xf86-video-vesa xorg-drivers;

# all drivers
#pacman --noconfirm --needed -S xf86-video-vesa;
#pacman --noconfirm --needed -S xorg-drivers;
#pacman --noconfirm --needed -S xf86-video-nv;
#pacman --noconfirm --needed -S nvidia-libgl;
#pacman --noconfirm --needed -S opencl-nvidia;


