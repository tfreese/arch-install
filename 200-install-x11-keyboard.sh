#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the X11 Keyboard
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


# List of Keyboardlayouts
localectl list-x11-keymap-layouts | less;

# List of Keyboardvariants
localectl list-x11-keymap-variants | less;

# Optional:
# use: localectl set-x11-keymap [layout] [model] [variant] [options]
# Example: localectl set-x11-keymap de [pc104/pc105] [de_nodeadkeys/nodeadkeys]

# Alternativ
# Eine Datei erzeugen /etc/X11/xorg.conf.d/20-keyboard.conf und folgendes hinzufügen:
#Section "InputClass"
#      Identifier "keyboard"
#      MatchIsKeyboard "yes"
#      Option "XkbLayout" "de"
#      Option "XkbModel" "pc105"
#      Option "XkbVariant" "de_nodeadkeys"
#EndSection
