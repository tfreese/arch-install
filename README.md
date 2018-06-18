#Installation-Script for archlinux.
#Use at your own risk !

Install the these scripts after boot from USB-Stick or CD:
- loadkeys [de-latin1/de-latin1-nodeadkeys];
- bash;
- pacman -Sy;
- pacman -S git;
- git clone https://github.com/tfreese/arch-install.git;
- chmod +x arch-install/*.sh;
- create Script ... use myDesktop.sh as Template;

After installing archlinux, the script are located in /arch-install folder and can be deleted.

