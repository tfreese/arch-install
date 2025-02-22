#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Audio software.
# https://aur.archlinux.org
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


cat /proc/asound/cards;
cat /etc/asound.conf;
#pcm.!default {
#	type hw
#	card Audigy2
#}
#ctl.!default {
#	type hw
#	card Audigy2
#}

#############################################################################################################
pacman --noconfirm --needed -S alsa-firmware alsa-lib alsa-oss alsa-plugins alsa-tools alsa-utils;
pacman --noconfirm --needed -S pulseaudio pulseaudio-alsa pulseaudio-equalizer;

pacman --noconfirm --needed -S gstreamer gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly;


# Codecs
pacman --noconfirm --needed -S a52dec faac faad2 ffms2 flac;
pacman --noconfirm --needed -S libdca libdv libdvdcss libmad libmpeg2 libtheora libfdk-aac libvorbis libxv;
pacman --noconfirm --needed -S mpg123 wavpack x264 x265 xvidcore;


# Tools
pacman --noconfirm --needed -S cd-discid;
pacman --noconfirm --needed -S cdparanoia;
pacman --noconfirm --needed -S ddrescue;
pacman --noconfirm --needed -S dvdbackup;
pacman --noconfirm --needed -S lame;
pacman --noconfirm --needed -S mp3splt;
pacman --noconfirm --needed -S playerctl;
pacman --noconfirm --needed -S vorbis-tools;
pacman --noconfirm --needed -S vorbisgain;
pacman --noconfirm --needed -S wavegain;

# flacgain (aur)
# mp3gain (aur)
# mp3val (aur)
#pacman --noconfirm --needed -S mplayer;
#pacman --noconfirm --needed -S mediainfo mediainfo-gui;
