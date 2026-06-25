#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Time Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


#############################################################################################################
# timesyncd: Ist schon Teil von systemd

if [ -d /etc/systemd/timesyncd.conf ]; then
	cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf_"$TIME";
fi

# 0.europe.pool.ntp.org 1.europe.pool.ntp.org 2.europe.pool.ntp.org 3.europe.pool.ntp.org
# ptbtime1.ptb.de ptbtime2.ptb.de ptbtime3.ptb.de

cat << EOF > /etc/systemd/timesyncd.conf
[Time]
NTP=0.europe.pool.ntp.org 1.europe.pool.ntp.org 2.europe.pool.ntp.org 3.europe.pool.ntp.org
FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
EOF

systemctl enable systemd-timesyncd.service;
systemctl start systemd-timesyncd.service;
systemctl status systemd-timesyncd.service;

#############################################################################################################
# ODER NTP

pacman --noconfirm --needed -S ntp;

sed -i_"$TIME" 's/0.arch.pool.ntp.org/ptbtime1.ptb.de iburst/' /etc/ntp.conf;
sed -i 's/1.arch.pool.ntp.org/ptbtime2.ptb.de iburst/' /etc/ntp.conf;
sed -i 's/2.arch.pool.ntp.org/ptbtime3.ptb.de iburst/' /etc/ntp.conf;
sed -i '/3.arch.pool.ntp.org/d' /etc/ntp.conf;
nano /etc/ntp.conf;

systemctl stop systemd-timesyncd;
systemctl disable systemd-timesyncd;
timedatectl set-ntp false;

# See 090-install-network.sh with NetworkManager, use DispatcherScript for NTP!
systemctl disable ntpd;
#systemctl enable ntpd;
#systemctl start ntpd;
#systemctl status ntpd;

ntpdate -u ptbtime1.ptb.de;
ntpd -gq;
