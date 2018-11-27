#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the ACPI power management Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

pacman --noconfirm --needed -S acpid;

systemctl enable acpid;
systemctl start acpid;
systemctl status acpid;
