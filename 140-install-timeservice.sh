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
# ODER CHRONY

pacman --noconfirm --needed -S chrony

cat << EOF > /etc/chrony.conf
# ====================================================================
# CHRONY CONFIGURATION FILE (/etc/chrony.conf)
# Optimized for Arch Linux - High Accuracy, Stability & Security
# ====================================================================

# --------------------------------------------------------------------
# 1. TIME SERVERS (NTP POOL & STRATUM 1/2 SERVICES)
# --------------------------------------------------------------------
# 'iburst' forces rapid synchronization on startup (4 requests in 6 seconds).
# 'maxsources 3' limits the active selection per pool to maintain diversity.
# NTS (Network Time Security)

# Default PTB (prefer) for local low-latency
server ptbtime1.ptb.de iburst nts prefer
server ptbtime2.ptb.de iburst nts prefer
server ptbtime3.ptb.de iburst nts prefer

# Fallback
pool de.pool.ntp.org iburst maxsources 3
pool europe.pool.ntp.org iburst maxsources 2

# Global Fallbacks, noselect = "query but do not use"
server time.cloudflare.com iburst nts noselect
server time.google.com iburst noselect

# --------------------------------------------------------------------
# 2. DRIFT & TIME CORRECTION
# --------------------------------------------------------------------
# Record the rate at which the system clock gains/losses time in a file.
# This allows chrony to remain accurate even if connection is temporarily lost.
driftfile /var/lib/chrony/drift

# Allow the clock to step (jump) instead of slew (gradually adjust) 
# if the adjustment is larger than 1 second, but ONLY during the first 3 updates.
makestep 1.0 3

# Enable hardware timestamping on all network interfaces that support it.
# This drastically reduces jitter and increases precision to microseconds.
hwtimestamp *

# --------------------------------------------------------------------
# 3. KERNEL SYNCHRONIZATION
# --------------------------------------------------------------------
# Let the Linux kernel update its real-time clock (RTC) every 11 minutes.
# Ensures that your hardware clock is accurate when you shut down.
rtcsync

# --------------------------------------------------------------------
# 4. LOGGING & DEBUGGING
# --------------------------------------------------------------------
# Define where log files are stored.
logdir /var/log/chrony

# Select what to log (measurements, statistics and clock tracking).
# Un-comment the line below if you need to debug accuracy issues.
# log measurements statistics tracking

# --------------------------------------------------------------------
# 5. SECURITY & ACCESS CONTROL
# --------------------------------------------------------------------
# By default, do not serve time to anyone. Act purely as a client.
# (If this should be an NTP server, add: allow 192.168.1.0/24)
deny all

# Drop root privileges and switch to the 'chrony' user after startup.
user chrony

# Control access to the 'chronyc' command-line monitoring tool.
# Restricted to the local root loopback interface.
bindcmdaddress 127.0.0.1
bindcmdaddress ::1

# Prevent chrony from freezing in memory leaks by dumping core files if it crashes.
dumponexit

EOF

systemctl enable chronyd;
systemctl start chronyd;
systemctl status chronyd;

Synchronisationsstatus prüfen: chronyc tracking
Verfügbare Zeitserver anzeigen: chronyc sources -v
Sofortige Zeitsynchronisation erzwingen: sudo chronyc makestep
Netzwerkverbindung wurde aufgebaut: chronyc -a onine > /dev/null 2>&1
Netzwerkverbindung wurde getrennt: chronyc -a offline > /dev/null 2>&1

Im NetworkManager NICHT den chrony-service stoppten und starten, dauert viel zu lang und ist nicht nötig.
 
#############################################################################################################
# ODER NTP (Veraltet)

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
