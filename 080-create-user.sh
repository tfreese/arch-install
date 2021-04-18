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
#sed -i_"$TIME" 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers;

echo "## (the '#' here does not indicate a comment)" >> /etc/sudoers;
echo "#includedir /etc/sudoers.d" >> /etc/sudoers;

cat << EOF > /etc/sudoers.d/tommy
# Reset environment by default
Defaults      env_reset

# Set default EDITOR to nano, and do not allow visudo to use EDITOR/VISUAL.
Defaults      editor=/usr/bin/nano, !env_editor


## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL) ALL


#User_Alias   ADMINS = USER1, USER2, USER3
#ADMINS ALL=(ALL) NOPASSWD: ALL


#Cmnd_Alias      SHUTDOWN = /usr/bin/shutdown, /usr/bin/systemctl poweroff, /usr/bin/systemctl stop kodi.service
Cmnd_Alias      MAINTAIN = /usr/bin/lsblk, /usr/bin/hddtemp, /usr/bin/smartctl, /usr/bin/nvme
Cmnd_Alias      LVM = /usr/bin/pvs, /usr/bin/vgs, /usr/bin/lvs

tommy ALL=(ALL) NOPASSWD: MAINTAIN, LVM
EOF

chmod 0440 /etc/sudoers.d/tommy;
visudo -c /etc/sudoers.d/tommy;
