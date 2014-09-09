#!/bin/bash
# Usage: dispatch-sshkey
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

. /etc/init.d/functions

for ip in `cat iplist`
do
 expect dispatch-sshkey.exp ~/.ssh/id_dsa.pub $ip >/dev/null 2>&1
 if [ $? -eq 0 ];then
    action "$ip" /bin/true
 else
    action "$ip" /bin/false
 fi
done
