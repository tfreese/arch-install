#!/bin/bash
#
# Thomas Freese
#
# ArchLinux Installation Script: Install the Software.
# https://aur.archlinux.org
#
#############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#############################################################################################################

set -euo pipefail
# –x für debug

pacman --noconfirm --needed -S nginx;
pacman --noconfirm --needed -S php-fpm;


systemctl enable php-fpm.service;
systemctl enable nginx.service;

systemctl start php-fpm.service;
systemctl start nginx.service;


cat << EOF > /etc/nginx/nginx.conf
user http http;
worker_processes  1;

events {
    worker_connections  256;
}


http {

    include       mime.types;
    default_type  application/octet-stream;
    
    server {
        listen       80;
        server_name  localhost;

        charset utf-8;
            
        location / {
            root   /srv/http;
            index  index.php index.html index.htm;
        }
        
        # PHP includieren oder direkt Konfigurieren
        include php.conf;
        
		location ~ \.php$ {
				fastcgi_pass    unix:/var/run/php-fpm/php-fpm.sock;
				root            /srv/http;
				fastcgi_index   index.php;
				include         fastcgi.conf;
		}

        location ~ /\.ht {
            deny  all;
        }
	}
}
EOF

cat << EOF > /etc/nginx/php.conf
location ~ \.php$ {
	fastcgi_pass    unix:/var/run/php-fpm/php-fpm.sock;
	root            /srv/http;
	fastcgi_index   index.php;
	include         fastcgi.conf;
}
EOF

#/etc/php/php.ini
#/etc/php/php-fpm.conf
cat << EOF > /etc/php/php-fpm.d/www.conf
listen.mode = 0660
pm = dynamic
pm.max_children = 5
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF


Problem:
php-fpm 'failed to chown() the socket'

Lösung: /etc/php/php-fpm.d/www.conf
Replace
;listen.acl_users =
;listen.acl_groups =
with
listen.acl_users = http
listen.acl_groups = http

#sudo mount --bind /home/tommy/monitor/ /srv/http/monitor/
#/home/tommy/monitor/    /srv/http/monitor/      none    bind    0 0
