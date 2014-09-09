#!/bin/bash
# Usage: dispatch-file
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

. /etc/init.d/functions

if [ $# -ne 2 ]
then
	echo "$0 file dir"
	exit 1
fi

for ip in `cat iplist`
do
	rsync -avzP $1 -e 'ssh -t -p 52113' disdata@$ip:~ > /dev/null 2>&1
	ssh -t -p 52113 disdata@$ip sudo rsync -avzP ~/$1 $2 > /dev/null 2>&1
 if [ $? -eq 0 ];then
    action "$ip" /bin/true
 else
    action "$ip" /bin/false
 fi
done
