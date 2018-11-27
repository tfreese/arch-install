################################################################################
installTimesyncd()
{
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
read -rp "Press any key...";
}

################################################################################
installNTP()
{
pacman --noconfirm -S ntp;

sed -i_"$TIME" 's/0.arch.pool.ntp.org/ptbtime1.ptb.de/' /etc/ntp.conf;
sed -i 's/1.arch.pool.ntp.org/ptbtime2.ptb.de/' /etc/ntp.conf;
sed -i 's/2.arch.pool.ntp.org/ptbtime3.ptb.de/' /etc/ntp.conf;
sed -i '/3.arch.pool.ntp.org/d' /etc/ntp.conf;
nano /etc/ntp.conf;

systemctl enable ntpd;
systemctl start ntpd;
systemctl status ntpd;
read -rp "Press any key...";
}

################################################################################
installRsync()
{
if [ $# -ne 1 ]; then
	echo "Usage: installRsync NETWORK"
	return 1
fi

NETWORK=$1

pacman --noconfirm -S rsync;

if [ ! -f /etc/rsyncd.conf ]; then
	touch /etc/rsyncd.conf;
fi

cp /etc/rsyncd.conf /etc/rsyncd.conf_"$TIME";

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

#[etc]
#    comment = /etc
#    path = /etc/
#    uid = root
#    gid = root

#[home]
#    comment = /home
#    path = /home/
#    uid = root
#    gid = root
EOF
nano /etc/rsyncd.conf;

cat << EOF > /etc/logrotate.d/rsyncd
/var/log/rsyncd {
        copytruncate
        rotate 8
        weekly
        compress
        missingok
}
EOF
nano /etc/logrotate.d/rsyncd;

echo "to activate:";
echo "systemctl enable rsyncd;"
echo "systemctl start rsyncd;"
echo "systemctl status rsyncd;"
read -rp "Press any key...";
}

################################################################################
installRsnapshot()
{
pacman --noconfirm -S rsnapshot;

cat << EOF > /etc/cron.daily/rsnapshot
#!/bin/sh
#nice -n 19 ionice -c3 rsnapshot daily
##nice -n 19 ionice -c2 -n7 rsnapshot daily
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
nano /etc/logrotate.d/rsnapshot;

echo "#35	*		*		*		*			root	nice -n 19 ionice -c3 rsnapshot hourly" >> /etc/crontab;

sed -i_"$TIME" 's/#no_create_root	1/no_create_root	1/' /etc/rsnapshot.conf;
sed -i 's/retain	alpha	6/retain	hourly	24/' /etc/rsnapshot.conf;
sed -i 's/retain	beta	7/retain	daily	30/' /etc/rsnapshot.conf;
sed -i 's/retain	gamma	4/retain	weekly	52/' /etc/rsnapshot.conf;
sed -i 's/#retain	delta	3/retain	monthly	12/' /etc/rsnapshot.conf;
sed -i 's/#logfile	\/var\/log\/rsnapshot/logfile	\/var\/log\/rsnapshot/' /etc/rsnapshot.conf;
sed -i 's/#rsync_short_args	-a/rsync_short_args	-a/' /etc/rsnapshot.conf;
sed -i 's/#rsync_long_args	--delete --numeric-ids --relative --delete-excluded/rsync_long_args	--delete-before --delete-excluded --numeric-ids --force/' /etc/rsnapshot.conf;
sed -i 's/#exclude	???/exclude	lost+found\//2' /etc/rsnapshot.conf;
sed -i 's/#exclude_file	\/path\/to\/exclude\/file/exclude_file	\/etc\/rsyncExcludes.conf/' /etc/rsnapshot.conf;
sed -i 's/#link_dest	0/link_dest	1/' /etc/rsnapshot.conf;
sed -i 's/#use_lazy_deletes	0/use_lazy_deletes	1/' /etc/rsnapshot.conf;

touch /etc/rsyncExcludes.conf;
mkdir -p /.snapshots
rsnapshot configtest;

read -rp "Press any key...";
nano /etc/rsnapshot.conf;
}

################################################################################
configIptables()
{
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

nano /etc/systemd/system/iptables.service;
ln -s /etc/firewall.sh /home/tommy/dokumente/skripts/firewall/firewall.sh;

echo "to activate:";
echo "systemctl enable iptables.service";
echo "systemctl start iptables.service";
echo "iptables.service needs Firewall-Script !";
read -rp "Press any key...";
}

################################################################################
# Logging, disable IPV6
configServices()
{
# limit logging
sed -i_"$TIME" 's/^#SystemMaxUse=/SystemMaxUse=200M/' /etc/systemd/journald.conf;

sed -i_"$TIME" 's/udp6/#udp6/' /etc/netconfig;
sed -i 's/tcp6/#tcp6/' /etc/netconfig;

cat << EOF > /etc/sysctl.d/99-sysctl.conf
vm.swappiness=0

dev.raid.speed_limit_min = 50000
dev.raid.speed_limit_max = 200000

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.wlan0.disable_ipv6 = 1
EOF
nano /etc/sysctl.d/99-sysctl.conf;

# Verhindern das Konsole nach dem Booten geleert wird.
mkdir /etc/systemd/system/getty@.service.d;

cat << EOF > /etc/systemd/system/getty@.service.d/nodisallocate.conf
[Service]
TTYVTDisallocate=no
EOF
}

################################################################################
installConsoleBasics()
{
pacman --noconfirm -S dosfstools; # vfat Treiber
pacman --noconfirm -S ntfs-3g; # ntfs Treiber
pacman --noconfirm -S rrdtool;
pacman --noconfirm -S bc; # Bash Arithmetik
}

################################################################################
installXServer()
{
pacman --noconfirm -S xorg-server xorg-xinit xorg-utils xorg-server-utils xorg-twm xorg-xclock xterm;
pacman --noconfirm -S ttf-dejavu;
#pacman --noconfirm -S xf86-input-synaptics; # For Laptops with Touchfield.
}

################################################################################
installKeyboard()
{
echo "List of Keyboardlayouts";
localectl list-x11-keymap-layouts | less

echo "List of Keyboardvariants";
localectl list-x11-keymap-variants | less

echo "Optional:";
echo "use: localectl set-x11-keymap [layout] [model] [variant] [options]";
echo "Example: localectl set-x11-keymap de [pc104/pc105] [de_nodeadkeys/nodeadkeys]";

# Alternativ
# Eine Datei erzeugen /etc/X11/xorg.conf.d/20-keyboard.conf und folgendes hinzufügen:
#Section "InputClass"
#      Identifier "keyboard"
#      MatchIsKeyboard "yes"
#      Option "XkbLayout" "de"
#      Option "XkbModel" "pc105"
#      Option "XkbVariant" "de_nodeadkeys"
#EndSection
}

################################################################################
installGraphicDriver()
{
echo "";
#pacman –Ss | grep xf86-video;
#echo "select the right driver based on the following output:";
#lspci -k | grep VGA;
#read -rp "Press any key...";

# all drivers
#pacman --noconfirm -S xorg-drivers;
pacman --noconfirm -S xf86-video-vesa

# Proprietärer Treiber: http://www.nvidia.com/object/unix.html
#pacman –Ss | grep nvidia;
#pacman -S nvidia;
#pacman -S nvidia-378.13-4;

#Für Hardware-Decoding (VDPAU):
pacman --noconfirm -S libva-vdpau-driver;

#pacman --noconfirm -S xf86-video-nv nvidia nvidia-utils; # nvidia-libgl, opencl-nvidia
}

################################################################################
installLoginmanager()
{
pacman --noconfirm –S gdm;

#systemctl enable gdm;
#systemctl start gdm;

#pacman --noconfirm –S slim archlinux-themes-slim;
#systemctl enable slim;
#systemctl start slim;
}

################################################################################
installCinnamon()
{
pacman --noconfirm -S cinnamon nemo faenza-icon-theme numix-gtk-theme gnome-keyring libgnome-keyring gnome-screenshot;
#pacman --noconfirm -S system-config-printer; # Drucker
#pacman --noconfirm -S blueberry; # Bluetooth
#yaourt cinnamon-sound-effects
#yaourt mint-sounds
#startx
#cp /etc/X11/xinit/xinitrc ~/.xinitrc
#exec cinnamon-session
}

################################################################################
installMate()
{
pacman --noconfirm -S mate mate-extra;
#startx
#cp /etc/X11/xinit/xinitrc ~/.xinitrc
#exec mate-session
}

################################################################################
installSonstigeGUI()
{
# GNOME
#pacman --noconfirm -S gnome gnome-extra;
#echo "exec gnome-session" > /home/USER/.xinitrc;

# XFCE
#pacman --noconfirm -S xfce4 xfce4-goodies human-icon-theme;
#echo "exec startxfce4" > /home/USER/.xinitrc;

# LXDE
#pacman --noconfirm -S lxde;
#echo "exec startlxde" > /home/USER/.xinitrc;

# Loginmanager GDM -> GNOME !!!
# pacman –S --noconfirm gdm;
# systemctl enable gdm;
# systemctl start gdm;

#pacman -S xorg-server-xephyr lightdm lightdm-gtk-greeter;
# systemctl disable slim; (if slim was previously installed)
#systemctl enable lightdm(.service);

# Wenn der Loginmanager disabled ist muss dieser mit "startx" aufgerufen werden.
}

################################################################################
installAudio()
{
pacman --noconfirm -S alsa-utils alsa-firmware alsa-lib alsa-plugins alsa-tools alsa-oss pulseaudio pulseaudio-alsa pavucontrol;
echo "audio devices:";
cat /proc/asound/cards;
echo "use nano /etc/asound.conf";
#nano /etc/asound.conf;
#pcm.!default {
#	type hw
#	card Audigy2
#}
#ctl.!default {
#	type hw
#	card Audigy2
#}
}

################################################################################
installCodecs()
{
pacman --noconfirm -S a52dec faac faad2 ffms2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libfdk-aac;
pacman --noconfirm -S libvorbis libxv gst-libav gst-plugins-good gst-plugins-ugly mp3gain vorbis-tools vorbisgain wavpack x264 x265 xvidcore;
pacman --noconfirm -S mediainfo mediainfo-gui ddrescue;
pacman --noconfirm -S libdvdcss; # Zum Auslesen von DVDs
pacman --noconfirm -S dvdbackup; # Zum Kopieren von DVDs
#pacman --noconfirm -S mplayer;
}

################################################################################
installDesktopBasics()
{
pacman --noconfirm -S gnome-terminal xfce4-terminal gnome-system-monitor gnome-calculator;
pacman --noconfirm -S gedit geany; # Texteditoren
pacman --noconfirm -S unzip unrar p7zip gimp xfburn; # Tools
pacman --noconfirm -S firefox firefox-i18n-de flashplugin; # Browser
pacman --noconfirm -S vlc cdrdao dvd+rw-tools handbrake; # Multimedia
pacman --noconfirm -S brasero; # CD-Brenner
pacman --noconfirm -S libreoffice; # Office-Clone
pacman --noconfirm -S evolution; # Outlook-Clone
pacman --noconfirm -S picard; # MusicBrainz Tagger

# TODO Java
#pacman --noconfirm -S icedtea-web;
}

################################################################################
installPrinter()
{
# https://wiki.archlinux.de/title/Drucker
pacman --noconfirm -S cups cups-pdf; # Drucker-API
pacman --noconfirm -S hplip; # HP Linux Inkjet Treiber
pacman --noconfirm -S gutenprint; # Generischer Treiber
pacman --noconfirm -S a2ps; # Verbesserter support für Text-Dateien
pacman --noconfirm -S gtk3-print-backends; # Auflistung des Druckers in Druck-Dialogen
pacman --noconfirm -S system-config-printer;

# Falls Drucker nicht erkannt wird.
cat << EOF > /etc/udev/rules.d/10-cups_device_link.rules
KERNEL=="lp[0-9]", SYMLINK+="%k", GROUP="lp"
EOF

systemctl enable org.cups.cupsd.service;
systemctl start org.cups.cupsd.service;
}
