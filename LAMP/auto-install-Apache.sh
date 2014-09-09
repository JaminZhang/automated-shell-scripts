#!/bin/bash
# Usage: auto-install-apache
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com


SOFT_DIR="/home/jamin/soft"
APACHE_VERSION="2.2.22"
APACHE_INSTALL_DIR="/app/apache-${APACHE_VERSION}"
APACHE_LN_DIR="/app/apache"

echo "-----Step 01: Uninstall rpm apache-----"
rpm -qa httpd*
for name in `rpm -qa httpd*`; do rpm -e --nodeps $name; done

echo "-----Step 02: Add apache user-----"
useradd -s /sbin/nologin -M apache
sleep 1

echo "-----Step 03: Download or upload apache cronlog soft-----"
[ ! -d "${SOFT_DIR}" ] && mkdir -p ${SOFT_DIR} 
cd ${SOFT_DIR}
[ ! -f httpd-${APACHE_VERSION}.tar.gz ] && \
wget http://archive.apache.org/dist/httpd/httpd-${APACHE_VERSION}.tar.gz

[ ! -f cronolog-1.6.2.tar.gz ] && \
wget http://cronolog.org/download/cronolog-1.6.2.tar.gz 
 


echo "-----Step 04: Install and configure apache-----"
cd ${SOFT_DIR}
tar xzf httpd-${APACHE_VERSION}.tar.gz
cd httpd-${APACHE_VERSION}

./configure \
--prefix=${APACHE_INSTALL_DIR} \
--enable-deflate \
--enable-expires \
--enable-headers \
--enable-modules=most \
--enable-so \
--enable-rewrite \
--with-mpm=worker

make && make install

ln -s ${APACHE_INSTALL_DIR} ${APACHE_LN_DIR}

cd ${APACHE_LN_DIR}/conf
sed -i "s/^User daemon/User apache/g" httpd.conf
sed -i "s/^Group daemon/Group apache/g" httpd.conf
sed -i "s/#ServerName www.example.com:80/ServerName 127.0.0.1:80/g" httpd.conf

echo "-----Step 05: Install cronlog-----"
cd ${SOFT_DIR}
tar xzf cronolog-1.6.2.tar.gz
cd cronolog-1.6.2
./configure \
make && make install

echo "-----Step 06: Run apache-----"
${APACHE_LN_DIR}/bin/apachectl start
echo "# Startup apache" >> /etc/rc.local
echo "${APACHE_LN_DIR}/bin/apachectl start" >> /etc/rc.local
tail -2 /etc/rc.local

echo "-----Step 07: Check apache-----"
ps -ef | grep http
echo "----------"
lsof -i tcp:80
echo "----------"
wget 127.0.0.1
