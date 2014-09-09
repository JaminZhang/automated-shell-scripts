#!/bin/bash
# Usage: auto-install-php
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com


SOFT_DIR="/home/jamin/soft"
PHP_VERSION="5.3.10"
PHP_INSTALL_DIR="/app/php-${PHP_VERSION}"
APACHE_INSTALL_DIR="/app/apache"
APACHE_APXS2="/app/apache/bin/apxs"
MYSQL_INSTALL_DIR="/app/mysql"

echo "-----Step 01: Check apache and mysql install-----"
[ ! -d ${APACHE_INSTALL_DIR} ] && "Please check apache." && exit 1
[ ! -d ${MYSQL_INSTALL_DIR} ] && "Please check mysql." && exit 1

echo
echo "-----Step 02: Check php rpm package-----"
rpm -qa zlib-devel libxml2-devel libjpeg-devel libpng-devel freetype-devel
sleep 2

echo
echo "-----Step 03: Install libiconv-----"
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
wget http://museum.php.net/php5/php-5.3.10.tar.gz
tar xzf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}
./configure \
--prefix=$PHP_INSTALL_DIR \
--with-apxs2=$APACHE_APXS2 \
--with-mysql=$MYSQL_INSTALL_DIR \
--with-xmlrpc \
--with-openssl \
--with-zlib \
--with-freetype-dir \
--with-gd \
--with-jpeg-dir \
--with-png-dir \
--with-iconv=/usr/local/libiconv \
--enable-short-tags \
--enable-sockets \
--enable-zend-multibyte \
--enable-soap \
--enable-mbstring \
--enable-static \
--enable-gd-native-ttf \
--with-curl \
--with-xsl \
--enable-ftp \
--with-libxml-dir

make && make install

ln -s $PHP_INSTALL_DIR /app/php

echo
echo "-----Step 05: Copy php.ini-----"
/bin/cp php.ini-production $PHP_INSTALL_DIR/lib/php.ini

echo
echo "-----Step 06: Config apache httpd.conf-----"
sed -i '/AddType application\/x-gzip \.gz \.tgz/ a\AddType application/x-httpd-php .php .php3' $APACHE_INSTALL_DIR/conf/httpd.conf
sed -i '/AddType application\/x-gzip \.gz \.tgz/ a\AddType application/x-httpd-php-source .phps' $APACHE_INSTALL_DIR/conf/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' $APACHE_INSTALL_DIR/conf/httpd.conf
grep php $APACHE_INSTALL_DIR/conf/httpd.conf

echo
echo "-----Step 07: Test php env-----"
cat > $APACHE_INSTALL_DIR/htdocs/jamin.php << EOF
<?php
phpinfo();
?>
EOF

${APACHE_INSTALL_DIR}/bin/apachectl graceful		# have problem while first graceful
sleep 2
curl http://127.0.0.1/jamin.php
