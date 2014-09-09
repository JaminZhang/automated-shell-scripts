#!/bin/bash
# Usage: auto-install-mysql
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

. /etc/init.d/functions

MYSQL_SOFT_DIR="/home/jamin/soft"
MYSQL_INSTALL_DIR="/app/mysql"
MYSQL_VERSION="5.1.65"

echo
echo "-----Step 01: Add mysql user-----"
useradd -s /sbin/nologin -M mysql
sleep 1

echo "-----Step 02: Download mysql-----"
mkdir -p ${MYSQL_SOFT_DIR}
cd ${MYSQL_SOFT_DIR}
[ ! -f mysql-${MYSQL_VERSION}.tar.gz ] && \
wget http://downloads.mysql.com/archives/get/file/mysql-${MYSQL_VERSION}.tar.gz
# Or upload mysql source code to the system.

echo
echo "-----Step 03: Install mysql-----"
cd ${MYSQL_SOFT_DIR} && \
tar zxf mysql-${MYSQL_VERSION}.tar.gz
cd mysql-${MYSQL_VERSION}

./configure \
--prefix=${MYSQL_INSTALL_DIR} \
--with-unix-socket-path=${MYSQL_INSTALL_DIR}/tmp/mysql.sock \
--localstatedir=${MYSQL_INSTALL_DIR}/data \
--enable-assembler \
--enable-thread-safe-client \
--with-mysqld-user=mysql \
--with-big-tables \
--without-debug \
--with-pthread \
--with-extra-charsets=complex \
--with-readline \
--with-ssl \
--with-embedded-server \
--enable-local-infile \
--with-plugins=partition,innobase \
#--with-plugin-PLUGIN \
--with-mysqld-ldflags=-all-static \
--with-client-ldflags=-all-static >> /tmp/install_mysql.log
[ $? -ne 0 ] && action "mysql configure" /bin/false && exit 1

make
[ $? -ne 0 ] && action "mysql make" /bin/false && exit 1

make install
[ $? -ne 0 ] && action "mysql make install" /bin/false && exit 1

action "mysql is installed successfully." /bin/true
