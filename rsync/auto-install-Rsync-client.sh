#!/bin/bash
# Usage: auto-install-Rsync-client
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com


# Init
RSYNC_SERVER="10.0.1.21"
CLIENT_FILE=`grep IPADDR /etc/sysconfig/network-scripts/ifcfg-eth1 | awk -F = '{print $2}'`

echo "123456" > /etc/rsync.password
chmod 600 /etc/rsync.password

# Check
ls -l /etc/rsync.password
cat /etc/rsync.password

# Test
echo "$CLIENT_FILE" >> /tmp/$CLIENT_FILE
rsync -avzP /tmp/$CLIENT_FILE rsync_backup@$RSYNC_SERVER::www --password-file=/etc/rsync.password

