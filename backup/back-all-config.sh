#!/bin/bash
# Usage: backup-all-config
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com


BACKUP_PATH="/server/backup"
IP=`awk '/IPADDR/' /etc/sysconfig/network-scripts/ifcfg-eth1 | awk -F "=" '{print $2}'`
BACKUP_SERVER="10.0.1.21"

[ ! -d ${BACKUP_PATH}/${IP} ] && mkdir -p ${BACKUP_PATH}/${IP}

# Backup config files in /etc eg: rc.local iptables rsyncd.conf exports 
cd /
tar czf ${BACKUP_PATH}/${IP}/etc_$(date +%F).tar.gz ./etc

# Backup cron
/bin/cp /var/spool/cron/root ${BACKUP_PATH}/${IP}/cron_root

# Backup apache config files
[ -d /app/apache ] && {
cd /app/apache
tar czf ${BACKUP_PATH}/${IP}/apache_conf_$(date +%F).tar.gz ./conf
}

# Backup nginx config files
[ -d /app/nginx ] && {
cd /app/nginx
tar czf ${BACKUP_PATH}/${IP}/nginx_conf_$(date +%F).tar.gz ./conf
}

# Backup scripts
cd /server/
tar czf ${BACKUP_PATH}/${IP}/server_scripts_$(date +%F).tar.gz ./scripts


# Rsync to backup server
rsync -azP ${BACKUP_PATH}/$IP rsync_backup@${BACKUP_SERVER}::backup/ --password-file=/etc/rsync.password >/dev/nul 2>&1

# Delete files 7 days ago
find ${BACKUP_PATH}/ -name "*.tar.gz" -mtime +7 | xargs rm -f



