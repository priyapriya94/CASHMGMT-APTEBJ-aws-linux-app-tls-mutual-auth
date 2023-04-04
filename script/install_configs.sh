#!/bin/bash
ls -ltr /tmp/upload

cp -R -f /tmp/upload/etc /

mkdir -p /etc/nginx/sites-enabled/

ln -s /etc/nginx/sites-available/bmotax.conf /etc/nginx/sites-enabled/bmotax.conf
ln -s /etc/nginx/sites-available/pendingapi.conf /etc/nginx/sites-enabled/pendingapi.conf
ln -s /etc/nginx/sites-available/tdtax.conf /etc/nginx/sites-enabled/tdtax.conf
ln -s /etc/nginx/sites-available/cert_auth_map.conf /etc/nginx/sites-enabled/cert_auth_map.conf

mkdir -p /opt/apt/scripts/

mkdir -p /opt/apt/ssl/

cp -R -f /tmp/upload/*.sh /opt/apt/scripts/

chmod +x /opt/apt/scripts/*.sh

chmod 0644 /etc/cron.d/crontab_acme

crontab /etc/cron.d/crontab_acme

wget https://www.amazontrust.com/repository/AmazonRootCA1.pem -P /opt/apt/ssl/
