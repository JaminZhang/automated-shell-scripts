#!/bin/bash
# Usage: auto-install-Nginx
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

SOFT_DIR="/home/jamin/soft"
NGINX_VERSION="1.4.7"
NGINX_INSTALL_DIR="/app/nginx-$NGINX_VERSION"
NGINX_LN_DIR="/app/nginx"

echo "-----Step 01: Install pcre-----"
[ ! -d "$SOFT_DIR" ] && mkdir $SOFT_DIR
cd $SOFT_DIR
[ ! -f pcre-8.35.tar.gz ] && \
wget http://downloads.sourceforge.net/project/pcre/pcre/8.35/pcre-8.35.tar.gz
[ ! -f pcre-8.35.tar.gz ] && exit 1

tar xzf pcre-8.35.tar.gz
cd pcre-8.35
./configure
make && make install

echo "-----Step 02: Add nginx user-----"
useradd -s /sbin/nologin -M nginx
sleep 1

echo "-----Step 03: Download and Install nginx soft-----"
[ ! -d "${SOFT_DIR}" ] && mkdir -p ${SOFT_DIR} 
cd ${SOFT_DIR}
[ ! -f nginx-${NGINX_VERSION}.tar.gz ] && \
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
[ ! -f nginx-${NGINX_VERSION}.tar.gz ] && exit 1

tar xzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}
./configure \
--prefix=$NGINX_INSTALL_DIR \
--user=nginx \
--group=nginx \
--with-http_stub_status_module \
--with-http_ssl_module

make && make install

ln -s $NGINX_INSTALL_DIR $NGINX_LN_DIR

echo "-----Step 04: Run nginx-----"
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig

$NGINX_LN_DIR/sbin/nginx -t
$NGINX_LN_DIR/sbin/nginx



echo "-----Step 05: Check nginx service-----"

ps -ef | grep nginx
echo "----------"
lsof -i tcp:80
echo "----------"
curl 127.0.0.1
echo "nginx is installed."
