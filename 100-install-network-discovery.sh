#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Network-Discovery Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

pacman --noconfirm --needed -S avahi;

#shares on a mac
pacman --noconfirm --needed -S nss-mdns;


systemctl enable avahi-daemon.service;
systemctl start avahi-daemon.service;
systemctl status avahi-daemon.service;

#hosts: files mymachines resolve [!UNAVAIL=return] dns myhostname

sed -i 's/files mymachines myhostname/files mymachines/g' /etc/nsswitch.conf;
sed -i 's/\[\!UNAVAIL=return\] dns/\[\!UNAVAIL=return\] mdns dns wins myhostname/g' /etc/nsswitch.conf;

# disable ipv6
# sed -i_"$TIME" 's/hosts: files dns/#hosts: files dns/' /etc/nsswitch.conf;
# sed -i '/#hosts: files dns/a hosts: files dns' /etc/nsswitch.conf;
