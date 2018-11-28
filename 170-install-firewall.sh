#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the firewall Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

pacman --noconfirm --needed -S iptables;

cat << EOF > /etc/logrotate.d/firewall
/var/log/firewall {
        copytruncate
        rotate 8
        weekly
        compress
        missingok
}
EOF

cat << EOF > /etc/systemd/system/iptables.service
[Unit]
Description=iptables Packet Filtering Framework
#Wants=network-pre.target
#Before=network-pre.target
Wants=network.target
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/etc/firewall.sh start
ExecReload=/etc/firewall.sh restart
ExecStop=/etc/firewall.sh stop

[Install]
WantedBy=multi-user.target
EOF

touch /etc/firewall.sh;

systemctl enable iptables.service;
systemctl start iptables.service;
systemctl status iptables.service;
