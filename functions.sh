#!/bin/bash
#
# Thomas Freese
#
# Install Functions for archlinux after the chroot.
# https://wiki.archlinux.de/title/Anleitung_für_Einsteiger

set -euo pipefail
# –x für debug

TIME=$(date '+%Y%m%d_%H%M%S')

################################################################################
pacstrap()
{
echo "";
read -rp "Press any key to pacstrap";
pacstrap /mnt base base-devel wpa_supplicant wireless_tools iw net-tools;

genfstab -U -p /mnt >> /mnt/etc/fstab;

echo " " >> /mnt/etc/fstab;
echo "Swap-Prio: DEVICE     none  swap   defaults,pri=1   0 0" >> /mnt/etc/fstab;
echo "#Bei SSD fstab Eintrag ändern in" >> /mnt/etc/fstab;
echo "#/dev/sda4	/	ext4	rw,defaults,noatime,nodiratime,discard	0	1" >> /mnt/etc/fstab;
echo "#NICHT /dev/sda4	/	ext4	rw,relatime,data=ordered	0	1" >> /mnt/etc/fstab;

nano /mnt/etc/fstab;

# copy scripts
cp -r ~/arch-install /mnt;

arch-chroot /mnt;
}

################################################################################
# sudo bash-completion parted gptfdisk mdadm git
installBasics()
{
pacman --noconfirm -S sudo bash-completion gptfdisk mdadm lvm2;
#pacman --noconfirm -S parted;
}

################################################################################
# Hostname, Nameserver, Locale
configBasics()
{
if [ $# -ne 2 ]; then
	echo "Usage: configBasics HOSTNAME NAMESERVER"
	return 1
fi

HOSTNAME=$1
NAMESERVER=$2

#loadkeys de-latin1;
echo "$HOSTNAME" > /etc/hostname;
echo "domain $DOMAIN" > /etc/resolv.conf;
echo "nameserver $NAMESERVER" >> /etc/resolv.conf;

echo "LANG=de_DE.UTF-8" > /etc/locale.conf;
echo "LC_COLLATE=C" >> /etc/locale.conf;
echo "LANGUAGE=de_DE" >> /etc/locale.conf

echo "KEYMAP=de-latin1" > /etc/vconsole.conf;
echo "FONT=lat9w-16" >> /etc/vconsole.conf
echo "FONT_MAP=8859-1_to_uni" >>/etc/vconsole.conf

ln -sfn /usr/share/zoneinfo/Europe/Berlin /etc/localtime;

nano /etc/resolv.conf;
nano /etc/locale.conf;
nano /etc/vconsole.conf;

#echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen;
#echo "de_DE ISO-8859-1" >> /etc/locale.gen;
#echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen;
sed -i_"$TIME" 's/^#de_DE/de_DE/g' /etc/locale.gen;
nano /etc/locale.gen;
locale-gen;

systemctl enable dhcpcd;

# ggf. Raid speichern
mdadm --detail --scan >> /etc/mdadm/mdadm.conf;
}

################################################################################
# Password, .nanorc
configRoot()
{
echo "";
echo "change password for root";
passwd;

cat << EOF > /root/.nanorc
# Cursor Position anzeigen
set constantshow
set linenumbers
EOF
}

################################################################################
genpasswd() {
local l=$1
 [ "$l" == "" ] && l = 20
 tr -dc A-Za-z0-9_. < /dev/urandom | head -c ${l} | xargs

#cat /dev/urandom | tr -dc 'a-zA-Z0-9_.' | fold -w 10 | head -n 1
#openssl rand -hex 12
#openssl rand -hex 12
}

#Iterate String:
#foo=string
#for (( i=0; i<${#foo}; i++ )); do
#  echo "${foo:$i:1}"
#done

################################################################################
makeKernel()
{
# https://wiki.archlinux.org/index.php/mkinitcpio#HOOKS
# HOOKS=(base udev autodetect modconf block mdadm keyboard keymap encrypt lvm2 filesystems fsck)
# HOOKS=(base systemd autodetect modconf block mdadm_udev keyboard sd-vconsole sd-encrypt sd-lvm2 filesystems fsck)
nano /etc/mkinitcpio.conf;
mkinitcpio -p linux;
}

################################################################################
installGrub()
{
if [ $# -ne 1 ]; then
	echo "Usage: installGrub DEVICE"
	return 1
fi

DEVICE=$1

pacman --noconfirm -S grub os-prober;

#sed -i_"$TIME" 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub;
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub;
nano /etc/default/grub;

grub-mkconfig -o /boot/grub/grub.cfg;
grub-install --target=i386-pc --recheck "$DEVICE";
}

################################################################################
createUser()
{
if [ $# -ne 4 ]; then
	echo "Usage: createUser GROUPID GROUPNAME USERID USERNAME"
	return 1
fi

GROUP_ID=$1
GROUP_NAME=$2
USER_ID=$3
USER_NAME=$4

groupadd --gid "$GROUP_ID" "$GROUP_NAME";
useradd  --gid "$GROUP_ID" --groups audio,network,optical,users,video,wheel --uid "$USER_ID" --create-home --home-dir "/home/$USER_NAME" --shell /bin/bash "$USER_NAME";
#gpasswd -a "$USER_NAME" wheel

# Systemuser  : useradd --system --no-create-home --shell=/bin/false USER
# User sperren: usermod -L USER

echo "change password for $USER_NAME";
passwd "$USER_NAME";

cat << EOF > "/home/$USER_NAME/.nanorc"
# Cursor Position anzeigen
set constantshow
set linenumbers
EOF

chown -R "$USER_NAME":"$GROUP_NAME" "/home/$USER_NAME";

sed -i_"$TIME" 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers;
nano /etc/sudoers;
}

################################################################################
installSSH()
{
if [ $# -ne 2 ]; then
	echo "Usage: installSSH LOCAL_IP ALLOW_USERS"
	return 1
fi

LOCAL_IP=$1
ALLOW_USERS=$2

pacman --noconfirm -S openssh;

sed -i_"$TIME" 's/#Port 22/Port 22/' /etc/ssh/sshd_config;
sed -i '/#ListenAddress ::/a'"#ListenAddress $LOCAL_IP" /etc/ssh/sshd_config;
sed -i 's/#X11Forwarding no/X11Forwarding no/' /etc/ssh/sshd_config;
sed -i 's/#Protocol 2/Protocol 2/' /etc/ssh/sshd_config;
sed -i 's/#ClientAliveInterval 0/#ClientAliveInterval 300/' /etc/ssh/sshd_config;
sed -i 's/#ClientAliveCountMax 3/#ClientAliveCountMax 3/' /etc/ssh/sshd_config;
sed -i '/#PermitRootLogin prohibit-password/a PermitRootLogin no' /etc/ssh/sshd_config;
echo ""  >> /etc/ssh/sshd_config;
#echo "PermitRootLogin no" >> /etc/ssh/sshd_config;
echo "AllowUsers $ALLOW_USERS" >> /etc/ssh/sshd_config;

nano /etc/ssh/sshd_config;

echo "to activate:";
echo "systemctl enable sshd;"
echo "systemctl start sshd;"
echo "systemctl status sshd;"
read -rp "Press any key...";
}

################################################################################
installCronie()
{
pacman --noconfirm -S cronie;

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
#*		*		*		*		*			root	/home/$USER_NAME/monitor/all-update.sh
#*/2	*		*		*		*			root	/home/$USER_NAME/monitor/all-graph.sh hour
#*/30	*		*		*		*			root	/home/$USER_NAME/monitor/all-graph.sh day
#0		*/2		*		*		*			root	/home/$USER_NAME/monitor/all-graph.sh week
EOF
nano /etc/crontab;
nano /etc/anacrontab;

systemctl enable cronie;
systemctl start cronie;
systemctl status cronie;
read -rp "Press any key...";
}

################################################################################
installACPID()
{
pacman --noconfirm -S acpid;

echo "to activate:";
echo "systemctl enable acpid;"
echo "systemctl start acpid;"
echo "systemctl status acpid;"
read -rp "Press any key...";
}

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
configNetwork()
{
if [ $# -lt 5 ]; then
	echo "Usage: configNetwork INTERFACE NETWORK IP BROADCAST GATEWAY [WLAN_SSID] [WLAN_PASSWORD]"
	return 1
fi

INTERFACE=$1
NETWORK=$2
IP=$3
BROADCAST=$4
GATEWAY=$5
METRIC=$6

if [ $# -eq 8 ]; then
	WLAN_SSID=$7
	WLAN_PASSWORD=$8
fi

if [ ! -d /etc/conf.d ]; then
	mkdir -p /etc/conf.d
fi

cat << EOF > /etc/conf.d/network-"$INTERFACE"
address=$IP
netmask=24
broadcast=$BROADCAST
gateway=$GATEWAY
network=$NETWORK
metric=$METRIC
EOF
nano /etc/conf.d/network-"$INTERFACE";

# Generischer Service erzeugen.
cat << EOF > /etc/systemd/system/network@.service
[Unit]
Description=Network startup %i
Wants=network.target
Before=network.target
BindsTo=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device

[Service]
Type=oneshot
RemainAfterExit=yes
EnvironmentFile=/etc/conf.d/network-%i

# wlan Routen löschen, falls notwendig.
#ExecStart=/sbin/ip route del default dev wlan0
#ExecStart=/sbin/ip route del ${network}/${netmask} via 0.0.0.0 dev wlan0

ExecStart=/sbin/ip link set dev %i mtu 1500 up
ExecStart=/sbin/ip addr add ${address}/${netmask} broadcast ${broadcast} dev %i
ExecStart=/sbin/ip route add default via ${gateway} dev %i metric ${metric}

ExecStop=/sbin/ip route del default dev %i
ExecStop=/sbin/ip route flush dev %i
ExecStop=/sbin/ip addr flush dev %i
ExecStop=/sbin/ip link set dev %i down

# wlan Routen erzeugen, falls notwendig.
#ExecStop=/sbin/ip route add default via ${gateway} dev wlan0
#ExecStop=/sbin/ip route add ${network}/${mask} via 0.0.0.0 dev wlan0

[Install]
WantedBy=multi-user.target
WantedBy=sys-subsystem-net-devices-%i.device
EOF

if [[ $INTERFACE == wlan* ]] ;
then
#ExecStart=/usr/bin/wpa_supplicant -B -i $INTERFACE -D nl80211,wext -c /etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf

#cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_"$TIME";
cat << EOF > /etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf
ctrl_interface=/var/run/wpa_supplicant
update_config=1
fast_reauth=1
ap_scan=1
# scan_ssid=1" # only for "Hidden"-SSIDs
# priority=n für Reihenfolge der Netzwerke

#network={
#	ssid=$WLAN_SSID
#	#key_mgmt=WPA-PSK
#	#pairwise=CCMP TKIP
#	#group=TKIP CCMP
#	#proto=RSN
#	psk=ENCODED PASSWORD
#}
EOF

wpa_passphrase "$WLAN_SSID" "$WLAN_PASSWORD" >> /etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf;
nano /etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf;
fi

#systemctl stop dhcpcd;
#systemctl disable dhcpcd;
#systemctl status dhcpcd;
#read -rp "Press any key...";

echo "to activate them: disable dhcpd before !";
echo "systemctl enable network@$INTERFACE.service;"
echo "systemctl enable wpa_supplicant@wlan0.service;"
echo "systemctl start network@$INTERFACE.service;"
echo "systemctl status network@$INTERFACE.service;"
read -rp "Press any key...";
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
nano /etc/systemd/journald.conf;

# disable ipv6
sed -i_"$TIME" 's/hosts: files dns/#hosts: files dns/' /etc/nsswitch.conf;
sed -i '/#hosts: files dns/a hosts: files dns' /etc/nsswitch.conf;
nano /etc/nsswitch.conf;

sed -i_"$TIME" 's/udp6/#udp6/' /etc/netconfig;
sed -i 's/tcp6/#tcp6/' /etc/netconfig;
nano /etc/netconfig;

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

systemctl enable avahi-daemon.service;
systemctl enable org.cups.cupsd.service;

systemctl start avahi-daemon.service;
systemctl start org.cups.cupsd.service;
}
