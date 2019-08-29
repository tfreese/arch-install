#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Config root Account
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

# Passwort ändern
passwd;

cat << EOF > /root/.nanorc
# Cursor Position anzeigen
set constantshow
set linenumbers
EOF


################################################################################
genpasswd() {
local length=$1
 [ "$l" == "" ] && l = 20
 tr -dc A-Za-z0-9_. < /dev/urandom | head -c ${length} | xargs

#cat /dev/urandom | tr -dc 'a-zA-Z0-9_.' | fold -w 10 | head -n 1
#openssl rand -hex 12
#openssl rand -base64 12

#Iterate String:
#foo=string
#for (( i=0; i<${#foo}; i++ )); do
#  echo "${foo:$i:1}"
#done
}
