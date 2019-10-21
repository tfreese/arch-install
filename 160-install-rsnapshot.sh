#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the rsnapshot Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


pacman --noconfirm --needed -S rsnapshot;

cat << EOF > /etc/cron.daily/rsnapshot
#!/bin/sh

#nice -n 19 ionice -c3 rsnapshot daily
##nice -n 19 ionice -c idle rsnapshot daily
EOF
chmod 744 /etc/cron.daily/rsnapshot;

cat << EOF > /etc/cron.weekly/rsnapshot
#!/bin/sh

#nice -n 19 ionice -c3 rsnapshot weekly
EOF
chmod 744 /etc/cron.weekly/rsnapshot;

cat << EOF > /etc/cron.monthly/rsnapshot
#!/bin/sh

#nice -n 19 ionice -c3 rsnapshot monthly
EOF
chmod 744 /etc/cron.monthly/rsnapshot;

cat << EOF > /etc/logrotate.d/rsnapshot
/var/log/rsnapshot {
        copytruncate
        rotate 8
        weekly
        compress
        missingok
}
EOF

echo "#35	*		*		*		*			root	nice -n 19 ionice -c3 rsnapshot hourly" >> /etc/crontab;

sed -i_"$TIME" 's/#no_create_root	1/no_create_root	1/' /etc/rsnapshot.conf;
sed -i 's/retain	alpha	6/retain	hourly	24/' /etc/rsnapshot.conf;
sed -i 's/retain	beta	7/retain	daily	30/' /etc/rsnapshot.conf;
sed -i 's/retain	gamma	4/retain	weekly	52/' /etc/rsnapshot.conf;
sed -i 's/#retain	delta	3/retain	monthly	12/' /etc/rsnapshot.conf;
sed -i 's/#verbose 2/verbose 2/' /etc/rsnapshot.conf;
sed -i 's/#loglevel 3/loglevel 2/' /etc/rsnapshot.conf;
sed -i 's/#logfile	\/var\/log\/rsnapshot/logfile	\/var\/log\/rsnapshot/' /etc/rsnapshot.conf;
sed -i 's/#rsync_short_args	-a/rsync_short_args	-a/' /etc/rsnapshot.conf;
sed -i 's/#rsync_long_args	--delete --numeric-ids --relative --delete-excluded/rsync_long_args	--numeric-ids --force/' /etc/rsnapshot.conf;
sed -i 's/#exclude	???/exclude	lost+found\//2' /etc/rsnapshot.conf;
sed -i 's/#ssh_args	-p 22/ssh_args	p 22 -i /home/tommy/.ssh/nopwd//2' /etc/rsnapshot.conf;
sed -i 's/#exclude_file	\/path\/to\/exclude\/file/exclude_file	\/etc\/rsyncExcludes.conf/' /etc/rsnapshot.conf;
sed -i 's/#link_dest	0/link_dest	1/' /etc/rsnapshot.conf;
sed -i 's/#use_lazy_deletes	0/use_lazy_deletes	1/' /etc/rsnapshot.conf;

touch /etc/rsyncExcludes.conf;
mkdir -p /.snapshots
rsnapshot configtest;
