#!/bin/bash
# Usage: auto-install-Rsync-Server
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com


# Init
CHECK_RSYNC=`rpm -q rsync | wc -l`
HOST_IP="10.0.1.0/24"

# Rsync Config
RSYNC_USER="rsync_backup"
PASSWD="123456"
PASSWD_FILE="/etc/rsync.passwd"
DATA_DIR="/data/backup"
RSYNC_SYS_USER="rsync"

# Load system functions
[ -f /etc/init.d/functions ] && . /etc/init.d/functions
RETVAL=0
[ `ps -ef | grep rsync | grep -v grep | wc -l` -eq 1 ] && {
echo "Rsync daemon is running, please stop rsync daemon first, and then run this script ($0)"
exit 1
}

# Check rsync
if [ "$CHECK_RSYNC" -eq 1 ]
then
	action "Rsync is installed." /bin/true
else
	echo "Begin to yum install rsync..."
	yum install rsync -y >> /tmp/rsync_install.log
	echo "-----split char-----" >> /tmp/rsync_install.log
	[ "$CHECK_RSYNC" -eq 1 ] && action "Rsync is installed." /bin/true || \
	action "Rsync is installed." /bin/false
fi

# Config rsyncd.conf
if [ ! -f /etc/rsynd.conf ]
then
	cat >> /etc/rsyncd.conf << EOF
######Rsync config start#####
uid = $RSYNC_SYS_USER
gid = $RSYNC_SYS_USER
use chroot = no
max connections = 200
timeout = 600
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsyncd.lock
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false
hosts allow = $HOST_IP
hosts deny = 0.0.0.0/32
auth users = $RSYNC_USER
secrets file = $PASSWD_FILE

[www]
path = $DATA_DIR
EOF
[ -f /etc/rsyncd.conf ] && action "Rsync config is completed." /bin/true
fi

# Create rsync password path
if [ ! -f "$PASSWD_FILE" ]
then
	echo "$RSYNC_USER:$PASSWD" > $PASSWD_FILE && \
	chmod 600 $PASSWD_FILE
fi

# Create rsync system user and DATADIR
[ `grep "^{$RSYNC_SYS_USER}:" /etc/passwd | wc -l` -lt 1 ] && \
useradd $RSYNC_SYS_USER -s /sbin/nologin -M

if [ ! -d "$DATA_DIR" ]
then
	mkdir -p $DATA_DIR
	chown -R $RSYNC_SYS_USER:$RSYNC_SYS_USER $DATA_DIR
fi

# Startup rsync
rsync --daemon && RETVAL=$?
[ `ps -ef | grep rsync | grep -v grep | wc -l` -eq 1 ] && {
action "Rsync configure and startup successful." /bin/true
exit $RETVAL
}
