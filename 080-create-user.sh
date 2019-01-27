#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Create Users
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

GROUP_ID="1000";
GROUP_NAME="linuxer";
USER_ID="1000":
USER_NAME="linuxer";

groupadd --gid "$GROUP_ID" "$GROUP_NAME";
useradd  --gid "$GROUP_ID" --groups audio,disk,games,network,optical,users,video,wheel --uid "$USER_ID" --create-home --home-dir "/home/$USER_NAME" --shell /bin/bash "$USER_NAME";
#gpasswd -a "$USER_NAME" wheel
#usermod -a -G disk $USER

# Systemuser  : useradd --system --no-create-home --shell=/bin/false USER
# User sperren: usermod -L USER

# Passwort ändern
passwd "$USER_NAME";

cat << EOF > "/home/$USER_NAME/.nanorc"
# Cursor Position anzeigen
set constantshow
set linenumbers
EOF

chown -R "$USER_NAME":"$GROUP_NAME" "/home/$USER_NAME";

# wheel UserGroup für sudo berechtigen
sed -i_"$TIME" 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers;
