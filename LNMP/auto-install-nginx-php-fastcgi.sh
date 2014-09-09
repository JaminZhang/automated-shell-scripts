#!/bin/bash
# Usage: auto-install-nginx-php-fastcgi
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com


SOFT_DIR="/home/jamin/soft"
PHP_VERSION="5.3.29"
NGINX_VERSION="1.4.7"
PHP_INSTALL_DIR="/app/php-${PHP_VERSION}"
PHP_LN_DIR="/app/php"
NGINX_INSTALL_DIR="/app/nginx-${NGINX_VERSION}"
NGINX_LN_DIR="/app/nginx"
MYSQL_INSTALL_DIR="/app/mysql"


echo "-----Step 01: Check nginx and mysql install-----"
[ ! -d ${APACHE_INSTALL_DIR} ] && "Please check nginx." && exit 1
[ ! -d ${MYSQL_INSTALL_DIR} ] && "Please check mysql." && exit 1

echo
echo "-----Step 02: Check php rpm package-----"
rpm -qa zlib-devel libxml2-devel libjpeg-devel libpng-devel freetype-devel
sleep 2

echo
echo "-----Step 03: Install php lib libiconv-----"
[ ! -d "$SOFT_DIR" ] && mkdir ${SOFT_DIR}
cd ${SOFT_DIR}
[ ! -f libiconv-1.14.tar.gz ] && \
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local/libiconv
make && make install

echo
echo "-----Step 04: Download and install php-----"
cd ${SOFT_DIR}
[ ! -f php-${PHP_VERSION}.tar.gz ] && \
wget http://cn2.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror
tar xzf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}
./configure \
--prefix=$PHP_INSTALL_DIR \
--with-mysql=$MYSQL_INSTALL_DIR \
--with-iconv=/usr/local/libiconv \
--with-xmlrpc \
--with-openssl \
--with-zlib \
--with-freetype-dir \
--with-gd \
--with-jpeg-dir \
--with-png-dir \
--with-libxml-dir \
--with-curl \
--with-xsl \
--enable-ftp \
--enable-short-tags \
--enable-sockets \
--enable-zend-multibyte \
--enable-soap \
--enable-mbstring \
--enable-static \
--enable-gd-native-ttf \
--enable-fpm \
--with-fpm-user=nginx \
--with-fpm-group=nginx

make && make install

ln -s $PHP_INSTALL_DIR $PHP_LN_DIR

echo
echo "-----Step 05: Copy php.ini-----"
/bin/cp php.ini-production $PHP_INSTALL_DIR/lib/php.ini
cd ../
echo "OK!"


