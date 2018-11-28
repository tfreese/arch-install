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
cat << EOF > /etc/sysctl.d/99-sysctl.conf
vm.swappiness=5

dev.raid.speed_limit_min = 50000
dev.raid.speed_limit_max = 200000

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.wlan0.disable_ipv6 = 1
EOF

# Verhindern das Konsole nach dem Booten geleert wird.
mkdir /etc/systemd/system/getty@.service.d;

cat << EOF > /etc/systemd/system/getty@.service.d/nodisallocate.conf
[Service]
TTYVTDisallocate=no
EOF
