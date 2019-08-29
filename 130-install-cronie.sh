#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Cronie Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

pacman --noconfirm --needed -S cronie;

# create crontab, if not exist
if [ ! -f /etc/crontab ]; then
	touch /etc/crontab;
fi

cp /etc/crontab /etc/crontab_"$TIME";

cat << EOF > /etc/crontab
# /etc/crontab: system-wide crontab

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Wochentag: sun=0=7, mon=1, tue=2, wed=3, thu=4, fri=5, sat=6
#Minute	Stunde	Tag		Monat	Wochentag	Wer		Kommando
#0-59	0-24	1-31	1-12	1-6			Wer		Kommando
#*		*		*		*		*			root	/srv/http/monitor/all-update.sh
#*/2	*		*		*		*			root	/srv/http/monitor/all-graph.sh hour
#*/30	*		*		*		*			root	/srv/http/monitor/all-graph.sh day
#0		*/2	*			*		*			root	/srv/http/monitor/all-graph.sh week
#35		*		*		*		*			root	nice -n 19 ionice -c3 rsnapshot hourly
EOF

nano /etc/crontab;
nano /etc/anacrontab;

systemctl enable cronie;
systemctl start cronie;
systemctl status cronie;
