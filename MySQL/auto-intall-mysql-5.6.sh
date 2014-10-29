#!/bin/bash
# Usage: auto install mysql
# Version: 1.3
# Author: Jamin Zhang
# Email: zhangjamin@163.com

. /etc/init.d/functions

MYSQL_SOFT_DIR="/root/soft"
MYSQL_VERSION="5.6.21"
MYSQL_INSTALL_DIR="/app/mysql-$MYSQL_VERSION"
MYSQL_LN_DIR="/app/mysql"

echo
echo "-----Step 01: Add mysql group and user-----"
groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql
sleep 1

echo "-----Step 02: Download mysql-----"
mkdir -p ${MYSQL_SOFT_DIR}
cd ${MYSQL_SOFT_DIR}
[ ! -f mysql-${MYSQL_VERSION}.tar.gz ] && \
wget http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-${MYSQL_VERSION}.tar.gz
#wget http://downloads.mysql.com/archives/get/file/mysql-${MYSQL_VERSION}.tar.gz mysql-5.1.65 
# Or upload mysql source code to the system.

echo
echo "-----Step 03: Install cmake and mysql-----"
yum install cmake -y

cd ${MYSQL_SOFT_DIR} && \
tar zxf mysql-${MYSQL_VERSION}.tar.gz
cd mysql-${MYSQL_VERSION}

cmake \
-DCMAKE_INSTALL_PREFIX=/app/mysql-${MYSQL_VERSION} \
-DMYSQL_DATADIR=/app/mysql-${MYSQL_VERSION}/data \
-DMYSQL_UNIX_ADDR=/app/mysql-${MYSQL_VERSION}/tmp/mysql.sock \
-DMYSQL_USER=mysql \
-DMYSQL_TCP_PORT=3306 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1  >> /tmp/install_mysql.log

[ $? -ne 0 ] && action "mysql configure" /bin/false && exit 1

make
[ $? -ne 0 ] && action "mysql make" /bin/false && exit 1

make install
[ $? -ne 0 ] && action "mysql make install" /bin/false && exit 1

[ $? -eq 0 ] && action "mysql is installed successfully." /bin/true

ln -s $MYSQL_INSTALL_DIR $MYSQL_LN_DIR
