#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Audio software
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
pacman --noconfirm --needed -S alsa-firmware;
pacman --noconfirm --needed -S alsa-lib;
pacman --noconfirm --needed -S alsa-oss;
pacman --noconfirm --needed -S alsa-plugins;
pacman --noconfirm --needed -S alsa-tools;
pacman --noconfirm --needed -S alsa-utils;
#pacman --noconfirm --needed -S pavucontrol;
pacman --noconfirm --needed -S pulseaudio;
pacman --noconfirm --needed -S pulseaudio-alsa;

pacman --noconfirm --needed -S gstreamer;
pacman --noconfirm --needed -S gst-libav;
pacman --noconfirm --needed -S gst-plugins-bad;
pacman --noconfirm --needed -S gst-plugins-base;
pacman --noconfirm --needed -S gst-plugins-good;
pacman --noconfirm --needed -S gst-plugins-ugly;


# Codecs
pacman --noconfirm --needed -S a52dec;
pacman --noconfirm --needed -S faac;
pacman --noconfirm --needed -S faad2;
pacman --noconfirm --needed -S ffms2;
pacman --noconfirm --needed -S flac;
pacman --noconfirm --needed -S libdca;
pacman --noconfirm --needed -S libdv;
pacman --noconfirm --needed -S libdvdcss; # Zum Auslesen von DVDs
pacman --noconfirm --needed -S libmad;
pacman --noconfirm --needed -S libmpeg2;
pacman --noconfirm --needed -S libtheora;
pacman --noconfirm --needed -S libfdk-aac;
pacman --noconfirm --needed -S libvorbis;
pacman --noconfirm --needed -S libxv;
pacman --noconfirm --needed -S mpg123;
pacman --noconfirm --needed -S wavpack;
pacman --noconfirm --needed -S x264;
pacman --noconfirm --needed -S x265;
pacman --noconfirm --needed -S xvidcore;


# Tools
pacman --noconfirm --needed -S cd-discid;
pacman --noconfirm --needed -S cdparanoia;
pacman --noconfirm --needed -S ddrescue;
pacman --noconfirm --needed -S dvdbackup; # Zum Kopieren von DVDs
pacman --noconfirm --needed -S flacgain;
pacman --noconfirm --needed -S lame;
#pacman --noconfirm --needed -S mediainfo mediainfo-gui;
# mp3gain (aur)
pacman --noconfirm --needed -S mp3splt;
# mp3val (aur)
#pacman --noconfirm --needed -S mplayer;
pacman --noconfirm --needed -S vorbis-tools;
pacman --noconfirm --needed -S vorbisgain;
pacman --noconfirm --needed -S wavegain;
