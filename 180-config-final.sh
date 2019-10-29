#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Final Configs
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


# Limit logging
sed -i_"$TIME" 's/^#SystemMaxUse=/SystemMaxUse=200M/' /etc/systemd/journald.conf;

# Disable IPv6
sed -i_"$TIME" 's/udp6/#udp6/' /etc/netconfig;
sed -i 's/tcp6/#tcp6/' /etc/netconfig;

# Config sysctl
cat << EOF > /etc/sysctl.d/10-sysctl.conf

# Möglichst wenig Swappen, 0 (aus) - 100 (max)
vm.swappiness=10
# cat /proc/sys/vm/swappiness


# Raid
dev.raid.speed_limit_min = 50000
dev.raid.speed_limit_max = 200000


# TCP SYN Flood Protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 3
# cat /proc/sys/net/ipv4/tcp_...


# IPv6 deaktivieren
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.wlan0.disable_ipv6 = 1
EOF

# Reload
systemctl restart systemd-sysctl.service;

# Festplaten-Caching deaktivieren (nur bei Raid)
pacman --noconfirm --needed -S hdparm;

cat << EOF > /etc/udev/rules.d/50-hdparm.rules
ACTION=="add|change", KERNEL=="sd[b-z]", ATTR{queue/rotational}=="1", RUN+="/usr/bin/hdparm -W0 /dev/%k"
EOF

# Verhindern das Konsole nach dem Booten geleert wird.
mkdir /etc/systemd/system/getty@.service.d;

cat << EOF > /etc/systemd/system/getty@.service.d/nodisallocate.conf
[Service]
TTYVTDisallocate=no
EOF
