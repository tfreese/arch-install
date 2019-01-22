#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Software
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


#############################################################################################################
# Themes
Minty


#############################################################################################################
# Editors
pacman --noconfirm --needed -S atom;
pacman --noconfirm --needed -S geany;
pacman --noconfirm --needed -S gedit;

pacman --noconfirm --needed -S texlive-most; # LaTex
pacman --noconfirm --needed -S texlive-lang;  # AddOn für nicht lateinische Sprachen
pacman --noconfirm --needed -S texmaker; # LaTeX editor
pacman --noconfirm --needed -S pandoc; # Konverter für Markdown


#############################################################################################################
# Entwicklung
pacman --noconfirm --needed -S docker-compose;
pacman --noconfirm --needed -S jdk-openjdk jre-openjdk  jre-openjdk-headless openjdk-doc;
pacman --noconfirm --needed -S git;
pacman --noconfirm --needed -S gradle;
pacman --noconfirm --needed -S maven;


#############################################################################################################
# Fonts
pacman --noconfirm --needed -S adobe-source-sans-pro-fonts;
pacman --noconfirm --needed -S cantarell-fonts;
pacman --noconfirm --needed -S noto-fonts;
pacman --noconfirm --needed -S tamsyn-font;
pacman --noconfirm --needed -S terminus-font;
pacman --noconfirm --needed -S ttf-bitstream-vera;
pacman --noconfirm --needed -S ttf-dejavu;
pacman --noconfirm --needed -S ttf-droid;
pacman --noconfirm --needed -S ttf-inconsolata;
pacman --noconfirm --needed -S ttf-liberation;
pacman --noconfirm --needed -S ttf-roboto;
pacman --noconfirm --needed -S ttf-ubuntu-font-family;


#############################################################################################################
# Multimedia
pacman --noconfirm --needed -S cdrdao;
pacman --noconfirm --needed -S dvd+rw-tools;
pacman --noconfirm --needed -S gimp;
pacman --noconfirm --needed -S handbrake;
pacman --noconfirm --needed -S picard; # MusicBrainz Tagger
pacman --noconfirm --needed -S vlc;


#############################################################################################################
# Office
pacman --noconfirm --needed -S evolution; # Outlook-Clone
pacman --noconfirm --needed -S libreoffice; # Office-Clone


#############################################################################################################
# System
pacman --noconfirm --needed -S bc; # Bash Arithmetik
pacman --noconfirm --needed -S conky;
pacman --noconfirm --needed -S gnome-calculator;
pacman --noconfirm --needed -S gnome-system-monitor;
#pacman --noconfirm --needed -S gnome-terminal;
pacman --noconfirm --needed -S hdparm;
pacman --noconfirm --needed -S hddtemp;
pacman --noconfirm --needed -S jq; # JSON processor
pacman --noconfirm --needed -S lm_sensors; # sensors-detect
pacman --noconfirm --needed -S samba smbclient;
pacman --noconfirm --needed -S smartmontools; # update-smart-drivedb
pacman --noconfirm --needed -S sshfs;
pacman --noconfirm --needed -S reflector pacman-contrib; # Test Arch-Mirrors
pacman --noconfirm --needed -S rsync rsnapshot;
pacman --noconfirm --needed -S rrdtool;
pacman --noconfirm --needed -S virtualbox;
pacman --noconfirm --needed -S xfce4-terminal;

#############################################################################################################
# Web
pacman --noconfirm --needed -S firefox;
pacman --noconfirm --needed -S firefox-i18n-de;
pacman --noconfirm --needed -S flashplugin;
pacman --noconfirm --needed -S lynx;
pacman --noconfirm --needed -S nginx;
pacman --noconfirm --needed -S php;
pacman --noconfirm --needed -S qbittorrent;

#############################################################################################################
# Utils
pacman --noconfirm --needed -S brasero; # CD-Brenner
pacman --noconfirm --needed -S keepass;
pacman --noconfirm --needed -S pigz; # parallel gzip
pacman --noconfirm --needed -S unrar;
pacman --noconfirm --needed -S unzip;
#pacman --noconfirm --needed -S xfburn;
