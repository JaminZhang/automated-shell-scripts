#!/bin/bash
# Usage: auto-install-Nginx
# Version: 1.3
# Author: Jamin Zhang
# Email: zhangjamin@163.com

SOFT_DIR="/home/jamin/soft"
PCRE_VERSION="8.35"
ZLIB_VERSION="1.2.8"
OPENSSL_VERSION="1.0.1i"
NGINX_VERSION="1.4.7"
NGINX_INSTALL_DIR="/app/nginx-$NGINX_VERSION"
NGINX_LN_DIR="/app/nginx"

echo "-----Step 01: Install pcre zlib openssl-----"
[ ! -d "$SOFT_DIR" ] && mkdir $SOFT_DIR
cd $SOFT_DIR
[ ! -f pcre-$PCRE_VERSION.tar.gz ] && \
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_VERSION.tar.gz
[ ! -f pcre-$PCRE_VERSION.tar.gz ] && exit 1

tar xzf pcre-$PCRE_VERSION.tar.gz
cd pcre-$PCRE_VERSION
./configure
make && make install
cd ../

[ ! -f zlib-$ZLIB_VERSION.tar.gz ] && \
wget http://zlib.net/zlib-$ZLIB_VERSION.tar.gz
[ ! -f zlib-$ZLIB_VERSION.tar.gz ] && exit 1

tar xzf zlib-$ZLIB_VERSION.tar.gz
cd zlib-$ZLIB_VERSION
./configure
make && make install
cd ../

[ ! -f openssl-$OPENSSL_VERSION.tar.gz ] && \
wget http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
[ ! -f openssl-$OPENSSL_VERSION.tar.gz ] && exit 1

tar xzf openssl-$OPENSSL_VERSION.tar.gz
cd openssl-$OPENSSL_VERSION
./config
make && make install
cd ../


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
--with-http_ssl_module \
--with-http_stub_status_module \
--with-pcre=${SOFT_DIR}/pcre-$PCRE_VERSION \
--with-zlib=${SOFT_DIR}/zlib-$ZLIB_VERSION \
--with-openssl=${SOFT_DIR}/openssl-$OPENSSL_VERSION



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
