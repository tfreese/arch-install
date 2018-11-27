#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Network Service
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug


# DHCP deaktivieren
systemctl stop dhcpcd;
systemctl disable dhcpcd;
systemctl status dhcpcd;


#############################################################################################################
# Interfaces umbenennen (enp6s0 -> eth0)
# MAC-Adresse ermitteln: cat /sys/class/net/enp6s0/address;

# Über udev
cat << EOF > /etc/udev/rules.d/10-network.rules
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="38:d5:47:e1:3d:a6", NAME="eth0"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="bc:05:43:02:c8:df", NAME="wlan0"
EOF

# Alternativ über systemd-networkd
cat << EOF > /etc/systemd/network/10-enp6s0.link
[Match]
MACAddress=38:d5:47:e1:3d:a6

[Link]
Description=Ethernet 0 Adapter
Name=eth0
EOF

#############################################################################################################
# LAN
if [ ! -d /etc/conf.d ]; then
	mkdir -p /etc/conf.d
fi

NETWORK="192.168.250.0"
BROADCAST="192.168.250.255"
GATEWAY="192.168.250.1"
#METRIC = Reihenfolge in den IP-Routen (ip route)

# Konfiguration anlegen
cat << EOF > /etc/conf.d/network-eth0
address="192.168.250.2"
netmask=24
broadcast=$BROADCAST
gateway=$GATEWAY
network=$NETWORK
metric="10"
EOF

# Generischer Netzwork@Service erzeugen.
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

systemctl enable network@eth0.service;
systemctl start network@eth0.service;
systemctl status network@eth0.service;


#############################################################################################################
# WLAN
pacman --noconfirm --needed -S wpa_supplicant;
pacman --noconfirm --needed -S wireless_tools;

cat << EOF > /etc/conf.d/network-wlan0
address="192.168.250.3"
netmask=24
broadcast=$BROADCAST
gateway=$GATEWAY
network=$NETWORK
metric="20"
EOF

# Netzwork@Service ist der gleiche
#ExecStart=/usr/bin/wpa_supplicant -B -i $INTERFACE -D nl80211,wext -c /etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf

#cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf_"$TIME";
cat << EOF > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
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

wpa_passphrase "$WLAN_SSID" "$WLAN_PASSWORD" >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf;

systemctl enable wpa_supplicant@wlan0.service;
systemctl start wpa_supplicant@wlan0.service;
systemctl status wpa_supplicant@wlan0.service;

systemctl enable network@wlan0.service;
systemctl start network@wlan0.service;
systemctl status network@wlan0.service;
