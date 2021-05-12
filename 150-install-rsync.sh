#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the rsync Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


pacman --noconfirm --needed -S rsync;

if [ ! -f /etc/rsyncd.conf ]; then
	touch /etc/rsyncd.conf;
fi

cp /etc/rsyncd.conf /etc/rsyncd.conf_"$TIME";

NETWORK="192.168.250.0"

cat << EOF > /etc/rsyncd.conf
uid = nobody
gid = nobody
use chroot = no
max connections = 4
#syslog facility = local5
pid file = /run/rsyncd.pid
log file = /var/log/rsyncd
log format = %t: host %h (%a) %o %f (%l bytes). Total %b bytes.
dont compress = *.gz *.tgz *.zip *.z *.rpm *.deb *.iso *.bz2 *.tbz *.dmg
transfer logging = no
list = no
read only = true
hosts allow = localhost, $NETWORK/24
hosts deny = *

[etc]
    comment = /etc
    path = /etc/
    uid = root
    gid = root

[home]
    comment = /home
    path = /home/
    uid = root
    gid = root
    
[backup]
    comment = /mnt/backup
    path = /mnt/backup
    uid = root
    gid = root 
    read only = no   
EOF

cat << EOF > /etc/logrotate.d/rsyncd
/var/log/rsyncd {
        copytruncate
        rotate 8
        weekly
        compress
        missingok
}
EOF

systemctl enable rsyncd;
systemctl start rsyncd;
systemctl status rsyncd;
