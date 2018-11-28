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


pacman --noconfirm --needed -S a2ps; # Verbesserter Support für Text-Dateien
pacman --noconfirm --needed -S cups cups-pdf; # Drucker-API
pacman --noconfirm --needed -S gtk3-print-backends; # Auflistung des Druckers in Druck-Dialogen
#pacman --noconfirm --needed -S gutenprint; # Generischer Treiber
pacman --noconfirm --needed -S hplip; # HP Linux Inkjet Treiber
pacman --noconfirm --needed -S system-config-printer;


systemctl enable org.cups.cupsd.service;
systemctl start org.cups.cupsd.service;
systemctl status org.cups.cupsd.service;


# Falls Drucker nicht erkannt wird.
cat << EOF > /etc/udev/rules.d/10-cups_device_link.rules
KERNEL=="lp[0-9]", SYMLINK+="%k", GROUP="lp"
EOF
