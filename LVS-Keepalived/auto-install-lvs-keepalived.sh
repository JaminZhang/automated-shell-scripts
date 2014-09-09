#!/bin/bash
# Usage: auto-install-lvs-keepalived
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

SOFT_DIR="/home/jamin/soft"

echo "-----Step 01: Download ipvsadm keepalived-----"

[ ! -d "$SOFT_DIR" ] && mkdir $SOFT_DIR

cd $SOFT_DIR

[ ! -f ipvsadm-1.24.tar.gz ] && \
wget http://www.linuxvirtualserver.org/software/kernel-2.6/ipvsadm-1.24.tar.gz
[ ! -f ipvsadm-1.24.tar.gz ] && exit 1

[ ! -f keepalived-1.2.7.tar.gz ] && \
wget http://www.keepalived.org/software/keepalived-1.2.7.tar.gz
[ ! -f keepalived-1.2.7.tar.gz ] && exit 1

echo "-----Step 02: Config and link kernel-----"

modprobe ip_vs

StrTmp=$(lsmod | grep ip_vs)
echo "modprobe---------->$StrTmp"
if [ -z "$StrTmp" ]; then
	echo "load module---------->Fail!" && exit 1
fi

SysVerTmp=$(uname -r)
flag=$(echo $SysVerTmp | grep xen | wc -l)
VerName="$(uname -r)-x86_64"
if [ $flag -ge 1 ]; then
	VerName="$(echo $SysVerTmp | sed 's/xen//g')-xen-x86_64"
fi

[ ! -e /usr/src/linux ] && \
ln -s /usr/src/kernels/$VerName /usr/src/linux

echo "-----Step 03: Install ipvsadm keepalived-----"

echo "-----Install ipvsadm-----"

cd ${SOFT_DIR}
tar zxf ipvsadm-1.24.tar.gz
cd ipvsadm-1.24
#./configure				# ipvsadm does not need configure
[ $? -ne 0 ] && echo "ERROR, ipvsadm configure." && exit 1
make && make install
[ $? -ne 0 ] && echo "ERROR, ipvsadm installing." && exit 1
cd ../
/sbin/ipvsadm


echo "-----Install keepalived-----"

cd ${SOFT_DIR}
tar zxf keepalived-1.2.7.tar.gz
cd keepalived-1.2.7
./configure
[ $? -ne 0 ] && echo "ERROR, keepalived configure." && exit 1
make && make install
[ $? -ne 0 ] && echo "ERROR, keepalived installing." && exit 1
cd ../


echo "-----Step 04: Config keepalived-----"

echo "-----Check follow file and dir-----"
ls -l /usr/local/sbin/keepalived
ls -l /usr/local/etc/rc.d/init.d/keepalived
ls -l /usr/local/etc/sysconfig/keepalived
ls -l /usr/local/etc/keepalived

echo "-----Copy keepalived command and config files-----"
\cp /usr/local/etc/rc.d/init.d/keepalived /etc/rc.d/init.d/
\cp /usr/local/etc/sysconfig/keepalived /etc/sysconfig/

mkdir -p /etc/keepalived
\cp /usr/local/etc/keepalived/keepalived.conf /etc/keepalived/
\cp /usr/local/sbin/keepalived /usr/sbin/

echo "-----Start keepalived-----"
/etc/init.d/keepalived start

echo "-----Set system ipv4 forward-----"
sed -i 's#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#g' /etc/sysctl.conf
sysctl -p


echo "-----Step 05: Check lvs and keepalived-----"

echo "ipvsadm -L -n"
ipvsadm -L -n

echo "ps -ef | grep keepalived"
ps -ef | grep keepalived

/etc/init.d/keepalived stop
echo "OK!"


