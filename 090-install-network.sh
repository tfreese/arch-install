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

pacman --noconfirm --needed -S iw;
pacman --noconfirm --needed -S net-tools;
pacman --noconfirm --needed -S ethtool;
pacman --noconfirm --needed -S wpa_supplicant;
pacman --noconfirm --needed -S wireless_tools;

#############################################################################################################
# NetworkManager - https://wiki.archlinux.org/title/NetworkManager
pacman --noconfirm --needed -S modemmanager;
pacman --noconfirm --needed -S networkmanager nm-connection-editor network-manager-applet networkmanager-openconnect networkmanager-openvpn;

# nmcli general;
# nmcli device;
# nmcli connection;
# nmcli networking on/off;
# nmcli radio wifi on/off;
# nmcli connection up/down ethernet-DEVICE;
# nmcli device connect/disconnect ethernet-DEVICE;
# nmcli device show DEVICE;
# VAR=nmcli -t device show DEVICE;
#
# nmcli connection add type ethernet ifname DEVICE;
# -> /etc/NetworkManager/system-connections/ethernet-DEVICE
# Filename must match with the ID in the file.

# Edit /etc/NetworkManager/system-connections/ethernet-DEVICE for static IP.
# [ipv4]
# address1=192.0.2.42/24
# dns=192.0.2.222;10.0.0.1;
# dns-search=
# method=manual

# Or by nmcli:
# nmcli connection edit ethernet-eth0

# nmcli> goto ipv4
# nmcli ipv4> set method manual
# nmcli ipv4> set addresses 10.0.0.42/24
# nmcli ipv4> set gateway 10.0.0.1
# nmcli ipv4> set dns 10.0.0.1
# nmcli ipv4> save
# nmcli ipv4> quit

# WLAN
# nmcli connection add ifname wlan0 type wifi ssid SSID:
# nmcli connection edit wifi-wlan0;
# nmcli> goto wifi
# nmcli 802-11-wireless> set mode infrastructure
# nmcli 802-11-wireless> back
# nmcli> goto wifi-sec
# nmcli 802-11-wireless-security> set key-mgmt wpa-psk
# nmcli 802-11-wireless-security> set psk SECRET
# nmcli 802-11-wireless-security> save
# nmcli 802-11-wireless-security> quit



# echo 'hello' | systemd-cat
# echo 'hello' | systemd-cat -p info
# echo 'hello' | systemd-cat -p warning
# echo 'hello' | systemd-cat -p emerg
# echo 'hello' | systemd-cat -t NetworkManager -p info
# journalctl -f

journalctl -r -u NetworkManager.service
journalctl -r -t NetworkManager
journalctl -r -t NetworkManager-dispatcher

systemctl stop systemd-networkd.service;
systemctl stop systemd-resolved.service;
systemctl disable systemd-networkd.service;
systemctl disable systemd-resolved.service;

# Disable /etc/systemd/resolved.conf

systemctl start NetworkManager.service;
systemctl status NetworkManager.service;
systemctl enable NetworkManager.service;

# Dispatcher-Script in /etc/NetworkManager/dispatcher.d/
cat << EOF > /etc/NetworkManager/dispatcher.d/10-iptables
#! /bin/bash

DEVICE=$1
ACTION=$2

readonly TIMESTAMP=$(date '+%Y%m%d-%H%M%S');
echo "$TIMESTAMP: $DEVICE - $ACTION" >> /tmp/NetworkManager.log;

case "$ACTION" in
        "up")
                echo "Restart Firewall" | systemd-cat -t NetworkManager-dispatcher -p info;
                /etc/init.d/firewall restart;
                ;;
        "down")
                echo "Restart Firewall" | systemd-cat -t NetworkManager-dispatcher -p info;
                /etc/init.d/firewall restart;
                ;;
        *)
                ;;
esac
EOF

cat << EOF > /etc/NetworkManager/dispatcher.d/99-wifi-auto-toggle
#! /bin/bash

INTERFACE=$1
ACTION=$2

LOG_PREFIX="WiFi Auto-Toggle"
ETHERNET_INTERFACE="Your_Ethernet_Interface"

if [ "$INTERFACE" = "$ETHERNET_INTERFACE" ]; then
    case "$2" in
        up)
            echo "$LOG_PREFIX ethernet up"
            nmcli radio wifi off
            ;;
        down)
            echo "$LOG_PREFIX ethernet down"
            nmcli radio wifi on
            ;;
    esac
    elif [ "$(nmcli -g GENERAL.STATE device show $ETHERNET_INTERFACE)" = "20 (unavailable)" ]; then
        echo "$LOG_PREFIX failsafe"
        nmcli radio wifi on
fi

exit 0;
EOF

sudo chown root:root /etc/NetworkManager/dispatcher.d/10-iptables;
chmod 755 /etc/NetworkManager/dispatcher.d/10-iptables;

# cat /sys/class/net/eth0/speed

#############################################################################################################
# DHCP deaktivieren
systemctl stop dhcpcd;
systemctl disable dhcpcd;
systemctl status dhcpcd;

# Netzwerk Adresse vergeben.
dhcpcd -b wlp5s0;

#############################################################################################################
# Falls resolve verwendet werden soll, nur für DHCP relevant.
# echo "domain fritz.box" > /etc/resolv.conf;
# echo "nameserver 192.168.250.1" >> /etc/resolv.conf;
nano /etc/systemd/resolved.conf;
DNS=192.168.250.1
Domains=fritz.box

mv /etc/resolv.conf /etc/resolv.conf.bak;
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;

systemctl enable systemd-resolved.service;
systemctl start systemd-resolved.service;
systemctl status systemd-resolved.service;


#############################################################################################################
# Interfaces umbenennen (enp6s0 -> eth0): Predictable Network InterfaceNames
# MAC-Adresse ermitteln: cat /sys/class/net/enp6s0/address;

cat << EOF > /etc/systemd/network/10-enp6s0.link
[Match]
MACAddress=38:d5:47:e1:3d:a6

[Link]
Description=Ethernet 0 Adapter
#Name=eth0
MTUBytes=1452
BitsPerSecond=1G
Duplex=full
WakeOnLan=off
EOF

# Alternativ über udev
cat << EOF > /etc/udev/rules.d/10-network.rules
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="38:d5:47:e1:3d:a6", NAME="eth0"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="bc:05:43:02:c8:df", NAME="wlan0"
EOF

#############################################################################################################
# LAN
cat << EOF > /etc/systemd/network/40-enp6s0.network
[Match]
Name=eth0

[Network]
#DHCP=yes/no/ipv4/ipv6
DHCP=no
Address=192.168.250.100/24
Gateway=192.168.250.1
DNS=192.168.250.1

[DHCP]
#UseRoutes=false
RouteMetric=10

[Link]
MTUBytes=1452
BitsPerSecond=1G
Duplex=full
WakeOnLan=off
RequiredForOnline=routable
EOF

# WLAN
cat << EOF > /etc/systemd/network/40-wlp5s0.network
[Match]
Name=wlp5s0

[Network]
#DHCP=yes
Gateway=192.168.250.1
Address=192.168.250.103/24
DNS=192.168.250.1
IgnoreCarrierLoss=3s

[DHCP]
RouteMetric=30

[Link]
RequiredForOnline=routable
Duplex=full
EOF

systemctl enable systemd-networkd;
systemctl start systemd-networkd;
systemctl status systemd-networkd;

#############################################################################################################
# WLAN

cat << EOF > /etc/wpa_supplicant/wpa_supplicant-wlp5s0.conf
ctrl_interface=/var/run/wpa_supplicant
update_config=1
fast_reauth=1
ap_scan=1
# scan_ssid=1" # only for "Hidden"-SSIDs
# priority=n für Reihenfolge der Netzwerke

network={
	ssid="$WLAN_SSID"
	psk="ENCODED PASSWORD"
	priority=1
}

#network={
#	ssid="$WLAN_SSID 2"
#	psk="ENCODED PASSWORD 2"
#	priority=2
#	key_mgmt=WPA-PSK
#	pairwise=CCMP TKIP
#	group=TKIP CCMP
#	proto=RSN
#}

EOF

wpa_passphrase "$WLAN_SSID" "$WLAN_PASSWORD" >> /etc/wpa_supplicant/wpa_supplicant-wlp5s0.conf;

systemctl enable wpa_supplicant@wlp5s0.service;
systemctl start wpa_supplicant@wlp5s0.service;
systemctl status wpa_supplicant@wlp5s0.service;

#############################################################################################################
# Fallback: DHCP für Ethernet

cat << EOF > /etc/systemd/network/99-dhcp.network
[Match]
Name=eth*

[Network]
DHCP=yes
EOF

#############################################################################################################
# Eigener Netzwerk-Service

if [ ! -d /etc/conf.d ]; then
	mkdir -p /etc/conf.d
fi

# Konfiguration anlegen
cat << EOF > /etc/conf.d/network-eth0
address="192.168.250.2"
netmask=24
broadcast=192.168.250.255
gateway=192.168.250.1
network=192.168.250.0
metric="10"
EOF

cat << EOF > /etc/conf.d/network-wlan0
address="192.168.250.3"
netmask=24
broadcast=192.168.250.255
gateway=192.168.250.1
network=192.168.250.0
metric="20"
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

ExecStart=/sbin/ip link set dev %i mtu 1452 up
#ExecStart=/usr/bin/wpa_supplicant -B -i $INTERFACE -D nl80211,wext -c /etc/wpa_supplicant/wpa_supplicant-$INTERFACE.conf
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

systemctl enable network@wlan0.service;
systemctl start network@wlan0.service;
systemctl status network@wlan0.service;
