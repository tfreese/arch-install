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


# timesyncd: Ist schon Teil von systemd
if [ -d /etc/systemd/timesyncd.conf ]; then
	cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf_"$TIME";
fi

cat << EOF > /etc/systemd/timesyncd.conf
[Time]
NTP=ptbtime1.ptb.de ptbtime2.ptb.de ptbtime3.ptb.de
FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
EOF

systemctl enable systemd-timesyncd.service;
systemctl start systemd-timesyncd.service;
systemctl status systemd-timesyncd.service;

#############################################################################################################
# ODER NTP
pacman --noconfirm --needed -S ntp;

sed -i_"$TIME" 's/0.arch.pool.ntp.org/ptbtime1.ptb.de/' /etc/ntp.conf;
sed -i 's/1.arch.pool.ntp.org/ptbtime2.ptb.de/' /etc/ntp.conf;
sed -i 's/2.arch.pool.ntp.org/ptbtime3.ptb.de/' /etc/ntp.conf;
sed -i '/3.arch.pool.ntp.org/d' /etc/ntp.conf;
nano /etc/ntp.conf;

systemctl enable ntpd;
systemctl start ntpd;
systemctl status ntpd;
