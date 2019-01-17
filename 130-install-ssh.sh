#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the SSH Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

pacman --noconfirm --needed -S openssh;


LOCAL_IP="192.168.250.2";
ALLOW_USERS="linuxer";

sed -i_"$TIME" 's/#Port 22/Port 22/' /etc/ssh/sshd_config;
sed -i '/#ListenAddress ::/a'"#ListenAddress $LOCAL_IP" /etc/ssh/sshd_config;
sed -i 's/#X11Forwarding no/X11Forwarding no/' /etc/ssh/sshd_config;
sed -i 's/#Protocol 2/Protocol 2/' /etc/ssh/sshd_config;
sed -i 's/#ClientAliveInterval 0/#ClientAliveInterval 300/' /etc/ssh/sshd_config;
sed -i 's/#ClientAliveCountMax 3/#ClientAliveCountMax 3/' /etc/ssh/sshd_config;
sed -i '/#PermitRootLogin prohibit-password/a PermitRootLogin no' /etc/ssh/sshd_config;
#echo "PermitRootLogin no" >> /etc/ssh/sshd_config;

echo ""  >> /etc/ssh/sshd_config;
echo "AllowUsers $ALLOW_USERS" >> /etc/ssh/sshd_config;


systemctl enable sshd;
systemctl start sshd;
systemctl status sshd;
