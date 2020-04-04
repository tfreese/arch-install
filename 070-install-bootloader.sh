#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the BootLoader
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

# Firmware Bug: TSC_DEADLINE, behebt microcode Warnung beim Booten
# /boot/intel-ucode.img
# dmesg | grep microcode
pacman --noconfirm --needed -S intel-ucode;

#############################################################################################################
# Prüfen, ob BIOS im UEFI Mode
efivar -l;
efibootmgr -v;
bootctl status;

# Verzeichnis muss vorhanden sein
ls /sys/firmware/efi;

# Devices ausgeben
lsblk -o NAME,LABEL,SIZE,FSTYPE,TYPE,MOUNTPOINT,MODEL,UUID;

#############################################################################################################
# UEFI

pacman --noconfirm --needed -S efibootmgr;

mkdir -p /boot/EFI/systemd;
mkdir -p /boot/EFI/BOOT;

# bootctl ist im systemd Package enthalten
bootctl [--path=/boot] install;
# Bei Raid wird 'bootctl install' nicht funktionieren, daher manuell installieren.
efibootmgr --create --disk /dev/sda --part 1 --label ArchLinux\ 1 --loader \\EFI\\systemd\\systemd-bootx64.efi;
efibootmgr --create --disk /dev/sdb --part 1 --label ArchLinux\ 2 --loader \\EFI\\systemd\\systemd-bootx64.efi;
efibootmgr --create --disk /dev/sdc --part 1 --label ArchLinux\ 3 --loader \\EFI\\systemd\\systemd-bootx64.efi;

bootctl [--path=/boot] update;
# Kopiert /usr/lib/systemd/boot/efi/systemd-bootx64.efi nach
# - /boot/EFI/systemd/systemd-bootx64.efi
# - /boot/EFI/BOOT/BOOTX64.EFI
# Bei Raid wird 'bootctl update' nicht funktionieren, daher manuell installieren.
cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi /boot/EFI/systemd/systemd-bootx64.efi;
cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi /boot/EFI/BOOT/BOOTX64.EFI;

# Bei einem Update von systemd-boot müssen die neuen *.efi Dateien wieder nach /boot/EFI kopiert werden.
# Manuell mit bootctl update;
# oder
# automatisch per pacman-Hook:
mkdir /etc/pacman.d/hooks;

cat << EOF > /etc/pacman.d/hooks/systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot: copy systemd-bootx64.efi
When = PostTransaction
# Exec = /usr/bin/bootctl update
Exec = /etc/pacman.d/hooks/systemd-boot-hook.sh
EOF

cat << EOF > /etc/pacman.d/hooks/systemd-boot-hook.sh
#!/bin/bash

/usr/bin/cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi /boot/EFI/systemd/systemd-bootx64.efi;
/usr/bin/cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi /boot/EFI/BOOT/BOOTX64.EFI;
EOF

chmod 700 /etc/pacman.d/hooks/systemd-boot.hook;
chmod 700 /etc/pacman.d/hooks/systemd-boot-hook.sh;


mkdir -p /boot/loader/entries;

cat << EOF > /boot/loader/loader.conf
default archlinux
timout 5
editor 0
auto-entries 1
# Für Windows Menü-Eintrag

console-mode max
# 0 = 80x25
# 1 = 80x50

EOF

cat << EOF > /boot/loader/entries/archlinux.conf
title ArchLinux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=/dev/vg0/root rw
# options root=/dev/mdx rw                      resume=/dev/... SWAP
# options root=PARTUUID=<PARTUUID aus blkid> rw resume=/dev/... SWAP
# options root=LABEL=... rw                     resume=/dev/... SWAP
# options root=UUID=... rw                      resume=/dev/... SWAP
# options cryptdevice=/dev/mdx:crypt_lvm root=/dev/vg0/root rw resume=/dev/... SWAP
EOF

# cp /boot/loader/entries/archlinux.conf /boot/loader/entries/archlinux-fallback.conf;

cat << EOF > /boot/loader/entries/archlinux-fallback.conf
title ArchLinux-Fallback
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux-fallback.img
options root=/dev/vg0/root rw
EOF


# systemd-boot sucht automatisch nach dem Eintrag 'EFI/Microsoft/Boot/Bootmgfw.efi' und erstellt einen Menü-Eintrag.
# Daher müssen nur die Windows UEFI-Dateien (vfat-Partition) in die Boot-Partition kopiert werden.
rsync -avh --progress /DEVICE/EFI/Microsoft/ /boot/EFI/Microsoft/;
# oder manuell
cat << EOF > /boot/loader/entries/windows.conf
title Windows
efi /EFI/Microsoft/Boot/bootmgfw.efi
options root=PARTUUID=6214-9628 rw
EOF

exit;
reboot;


#############################################################################################################
# SYSLINUX (Legacy Boot)

pacman --noconfirm --needed -S syslinux;

mkdir /boot/syslinux;

# -i (install the files)
# -a (mark the partition active with the boot flag)
# -m (install the MBR boot code)
syslinux-install_update -i -a -m;

# Edit
nano /boot/syslinux/syslinux.cfg;
# TIMEOUT 30 						# 3 Sekunden
# APPEND root=/dev/vg0/root rw
# APPEND cryptdevice=/dev/sda2:crypt_lvm root=/dev/vg0/root rw
# APPEND root=/dev/sda3 rw rootflags=subvol=root
# INITRD ../intel-ucode.img
# INITRD ../initramfs-linux.img

# Manuelle Installation ohne syslinux-install_update
cp /usr/lib/syslinux/bios/*.c32 /boot/syslinux/;
extlinux --install /boot/syslinux; # Install Bootloader
dd if=/usr/lib/syslinux/bios/mbr.bin of=/dev/sda bs=440 count=1 conv=notrunc status=progress; # Install MBR

exit;
reboot;


#############################################################################################################
# GRUB2 (Legacy Boot)

pacman --noconfirm --needed -S grub os-prober;

#sed -i_"$TIME" 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub;
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub;

mkdir /boot/grub;
grub-mkconfig -o /boot/grub/grub.cfg;
grub-install --target=i386-pc --recheck /dev/sda;
grub-install --target=i386-pc --recheck /dev/sdb;
grub-install --target=i386-pc --recheck /dev/sdc;

exit;
reboot;


#############################################################################################################

# vim
# Ausgabe von Befehl einfügen: :r!unix_command
# Zeile löschen: dd

efibootmgr:
-c; --create	= create new variable bootnum and add to bootorder
-d; --disk		= (defaults to /dev/sda) containing loader
-p; --part		= (defaults to 1) containing loader
-L; --label		= Boot manager display label (defaults to "Linux")
-l; --loader	= (defaults to "\EFI\/boot/EFI\grub.efi")
-u; --unicode	= handle extra args as UCS-2 (default is ASCII)
-v; --verbose	= print additional information

# Boot-Eintrag löschen
sudo efibootmgr;
	-> Boot0003* ArchLinux 3
efibootmgr -b 0003 -B ;



efibootmgr -c -d /dev/sda -p 1 -L Arch\ Linux\ 1 -l \\EFI\\gummiboot\\gummibootx64.efi
efibootmgr -c -d /dev/sdb -p 1 -L Arch\ Linux\ 2 -l \\EFI\\gummiboot\\gummibootx64.efi

efibootmgr --create --disk /dev/sda --part 1 --label "Precise - GRUB2" --loader \\EFI\\ubuntu\\grubx64.efi
efibootmgr --create --disk /dev/sda --part 2 --label "Fedora Grub" --loader /EFI/fedora/grubx64.efi
efibootmgr --create --disk /dev/sda --part 3 --label "rEFInd Boot Manager" --loader /EFI/refind/refind_x64.efi --verbose
efibootmgr --disk /dev/sdX --part Y --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX rw initrd=\initramfs-linux.img' --verbose
efibootmgr -c -d /dev/sda -p 1 -l \vmlinuz-linux -L "Arch Linux efistub" -u "initrd=/initramfs-linux.img root=LABEL=p_arch rw"
efibootmgr -c -d /dev/sda -p 1 -l \vmlinuz-linux -L "Arch Linux fallback efistub" -u "initrd=/initramfs-linux-fallback.img root=LABEL=p_arch rw"
