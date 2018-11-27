#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Prepare the Installation
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

# Deutsches Tastatur-Layout: de-latin1/de-latin1-nodeadkeys
loadkeys;

bash;

# Packages vom USB-Stick aktualisieren
pacman -Sy;

# pacman -S git;
# git clone https://github.com/tfreese/arch-install.git;
# chmod +x arch-install/*.sh;
# nano arch-install/archi-install.conf;
#
# read -rp "Press any key to pacstrap";
# TIME=$(date '+%Y%m%d_%H%M%S')
