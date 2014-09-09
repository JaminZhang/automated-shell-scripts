#!/bin/bash
# Usage: auto-install-nginx-php-ext
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com


SOFT_DIR="/home/jamin/soft"
NGINX_VERSION="1.4.7"
PHP_VERSION="5.3.29"
PHP_INSTALL_DIR="/app/php-${PHP_VERSION}"
PHP_LN_DIR="/app/php"
NGINX_INSTALL_DIR="/app/nginx-${NGINX_VERSION}"
NGINX_LN_DIR="/app/nginx"
MYSQL_INSTALL_DIR="/app/mysql"

echo "-----Step 01: Check nginx and mysql install-----"
[ ! -d ${NGINX_INSTALL_DIR} ] && "Please check nginx." && exit 1
[ ! -d ${MYSQL_INSTALL_DIR} ] && "Please check mysql." && exit 1

echo
echo "-----Step 02: env config-----"
echo "export LC_ALL=C" >> /etc/profile
source /etc/profile

echo "-----Step 03: php ext install-----"
[ ! -d "$SOFT_DIR" ] && mkdir $SOFT_DIR

[ ! -f eaccelerator-0.9.6.tar.bz2 ] && \
wget http://downloads.sourceforge.net/project/eaccelerator/eaccelerator/eAccelerator%200.9.6/eaccelerator-0.9.6.tar.bz2
[ ! -f eaccelerator-0.9.6.tar.bz2 ] && exit 1

tar xjf eaccelerator-0.9.6.tar.bz2
cd eaccelerator-0.9.6
$PHP_LN_DIR/bin/phpize
./configure \
--enable-eaccelerator=shared \
--with-php-config=$PHP_LN_DIR/bin/php-config
make && make install
cd ../

[ ! -f memcache-2.2.7.tgz  ] && \
wget http://pecl.php.net/get/memcache-2.2.7.tgz
[ ! -f memcache-2.2.7.tgz ] && exit 1

tar xzf memcache-2.2.7.tgz
cd memcache-2.2.7
$PHP_LN_DIR/bin/phpize
./configure \
--with-php-config=$PHP_LN_DIR/bin/php-config
make && make install
cd ../

cd $SOFT_DIR
[ ! -f ImageMagick.tar.gz ] && \
wget http://www.imagemagick.org/download/ImageMagick.tar.gz
[ ! -f ImageMagick.tar.gz ] && exit 1

tar xzf ImageMagick.tar.gz
cd ImageMagick-6.8.9-7
./configure
make && make install
cd ../


[ ! -f imagick-3.1.2.tgz ] && \
wget http://pecl.php.net/get/imagick-3.1.2.tgz
[ ! -f imagick-3.1.2.tgz ] && exit 1

tar xzf imagick-3.1.2.tgz
cd imagick-3.1.2
$PHP_LN_DIR/bin/phpize
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
./configure \
--with-php-config=$PHP_LN_DIR/bin/php-config
make && make install

ls $PHP_LN_DIR/lib/php/extensions/no-debug-zts-20090626


echo "-----Step 04: php.ini config -----"
cd $PHP_LN_DIR/lib
sed -i 's#; extension_dir = "./"#extension_dir = "$PHP_LN_DIR/lib/php/extensions/no-debug-zts-20090626"#g' php.ini		# extension_dir should set as VARIABLE
grep "extension_dir" php.ini

echo "extension = memcache.so" >> php.ini
echo "extension = imagick.so" >> php.ini
tail -5 php.ini

cat >> php.ini << EOF
extension = eaccelerator.so
; eAccelerator
eaccelerator.shm_size = "16"
eaccelerator.cache_dir = "/tmp/eaccelerator"
eaccelerator.enable = "1"
eaccelerator.optimizer = "1"
eaccelerator.check_mtime = "1"
eaccelerator.debug = "0"
eaccelerator.filter = ""
eaccelerator.shm_max = "0"
eaccelerator.shm_ttl = "0"
eaccelerator.prune_period = "0"
eaccelerator.shm_only = "0"
eaccelerator.compress = "1"
eaccelerator.compress_level = "9"
EOF

mkdir /tmp/eaccelerator
#chmod -R 777 /tmp/eaccelerator
chown -R nginx:nginx /tmp/eaccelerator


$PHP_LN_DIR/bin/php -v | grep -i eacc


