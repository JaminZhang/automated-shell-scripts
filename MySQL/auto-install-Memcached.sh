#!/bin/bash
# Usage: auto-install-Memcached
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

. /etc/init.d/functions

SOFT_DIR="/home/jamin/soft"
LIBEVENT_VERSION="2.0.21"
MEMCACHED_VERSION="1.4.15"
LIBEVENT_INSTALL_DIR="/usr/local/libevent-${LIBEVENT_VERSION}"
MEMCACHED_INSTALL_DIR="/app/memcached-${MEMCACHED_VERSION}"

echo "-----Step 01: Download libevent and memcached-----"
cd ${SOFT_DIR} && \
[ ! -f libevent-${LIBEVENT_VERSION}-stable.tar.gz ] && \
wget --no-check-certificate https://github.com/downloads/libevent/libevent/libevent-${LIBEVENT_VERSION}-stable.tar.gz		# download problem

cd ${SOFT_DIR} && \
[ ! -f memcached-${MEMCACHED_VERSION}.tar.gz ] && \
wget --no-check-certificate https://memcached.googlecode.com/files/memcached-${MEMCACHED_VERSION}.tar.gz					# download problem
# Or upload mysql source code to the system.


echo
echo "-----Step 02: Install libevent-----"
cd ${SOFT_DIR} && \
tar zxf libevent-${LIBEVENT_VERSION}-stable.tar.gz && \
cd libevent-${LIBEVENT_VERSION}-stable && \
 ./configure  \
--prefix=${LIBEVENT_INSTALL_DIR}

make && make install
[ $? -ne 0 ] && action "libevent make install" /bin/false && exit 1
cd ../

echo
echo "-----Step 03: Install memcached-----"
cd ${SOFT_DIR} && \
tar zxf memcached-${MEMCACHED_VERSION}.tar.gz && \
cd memcached-${MEMCACHED_VERSION} && \
 ./configure  \
--prefix=${MEMCACHED_INSTALL_DIR} \
--with-libevent=${LIBEVENT_INSTALL_DIR}

make && make install
[ $? -ne 0 ] && action "memcached make install" /bin/false && exit 1
cd ../

echo
echo "-----Step 04: Startup memcached-----"
echo "export PATH=$PATH:${MEMCACHED_INSTALL_DIR}/bin" >> /etc/profile
source /etc/profile
which memcached
memcached -m 4096m -p 12111 -d -u root -P /var/run/memcached.pid -c 4096
memcached -m 4096m -p 12112 -d -u root -P /var/run/memcached2.pid -c 4096

[ `ps -ef | grep memcached | grep -v grep | wc -l` -eq 2 ] && {
action "memcached startup successful." /bin/true
}
