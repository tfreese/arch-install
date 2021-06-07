#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Printer
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


# Web-GUI: http://localhost:631/
pacman --noconfirm --needed -S a2ps; # Verbesserter Support für Text-Dateien
pacman --noconfirm --needed -S cups bluez-cups cups-pdf; # Drucker-API
pacman --noconfirm --needed -S gtk3-print-backends; # Auflistung des Druckers in Druck-Dialogen
#pacman --noconfirm --needed -S gutenprint; # Generischer Treiber
pacman --noconfirm --needed -S system-config-printer;

pacman --noconfirm --needed -S hplip; # HP Linux Inkjet Treiber
# Leider fehlt der Firmware-Treiber bei hplip, diesen aus dem aur-Repository manuell installieren.
# https://aur.archlinux.org/hplip-plugin.git


systemctl enable cups.service;
systemctl start cups.service;
systemctl status cups.service;


# Falls Drucker nicht erkannt wird.
cat << EOF > /etc/udev/rules.d/10-cups_device_link.rules
KERNEL=="lp[0-9]", SYMLINK+="%k", GROUP="lp"
EOF
