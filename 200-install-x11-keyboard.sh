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


# localectl set-x11-keymap [layout] [model] [variant] [options]
# Erzeugt die Datei /etc/X11/xorg.conf.d/00-keyboard.conf
localectl set-x11-keymap de [pc104/pc105] nodeadkeys

# List of Keyboardlayouts
# localectl list-x11-keymap-layouts | less;

# List of Keyboardvariants
# localectl list-x11-keymap-variants | less;

# Alternativ
# Eine Datei erzeugen /etc/X11/xorg.conf.d/00-keyboard.conf und folgendes hinzufügen:
#Section "InputClass"
#      Identifier "keyboard"
#      MatchIsKeyboard "yes"
#      Option "XkbLayout" "de"
#      Option "XkbModel" "pc105"
#      Option "XkbVariant" "de_nodeadkeys"
#EndSection

# Oder
# Section "InputClass"
#         Identifier "system-keyboard"
#         MatchIsKeyboard "on"
#         Option "XkbLayout" "de"
#         Option "XkbModel" "pc104"
#         Option "XkbVariant" "nodeadkeys"
# EndSection
