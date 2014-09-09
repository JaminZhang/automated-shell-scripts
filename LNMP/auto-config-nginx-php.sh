#!/bin/bash
# Usage: auto-config-nginx-php
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

. /etc/init.d/functions

SOFT_DIR="/home/jamin/soft"
NGINX_VERSION="1.4.7"
PHP_VERSION="5.3.29"
PHP_INSTALL_DIR="/app/php-${PHP_VERSION}"
PHP_LN_DIR="/app/php"
NGINX_INSTALL_DIR="/app/nginx-${NGINX_VERSION}"
NGINX_LN_DIR="/app/nginx"
MYSQL_INSTALL_DIR="/app/mysql"

echo "-----Step 01: Make site dir-----"
mkdir -p /var/html/{www,bbs,blog,wiki,status}
chown -R nginx.nginx /var/html/{www,bbs,blog,wiki,status}
tree /var/html/

echo
echo "-----Step 02: Config nginx php-fpm-----"
[ ! -e conf.zip ] && {
echo "conf.zip is not exist."
exit 1
}

unzip conf.zip

mkdir -p /app/logs

[ ! -e conf/php-fpm.conf-$PHP_VERSION ] && {
echo "conf/php-fpm.conf-$PHP_VERSION is not exist."
exit 1
}

/bin/cp conf/php-fpm.conf-$PHP_VERSION $PHP_LN_DIR/etc/php-fpm.conf

echo "-----Step 03: Start php-cgi processes-----"
echo "restart php-fpm"
$PHP_LN_DIR/sbin/php-fpm -t
pkill php-fpm
sleep 5
$PHP_LN_DIR/sbin/php-fpm

echo "check php-fpm port"
netstat -lnt | grep 9000
lsof -i :9000
ps -ef | grep php-cgi | grep -v grep
sleep 3


echo "-----Step 04: Config and run nginx -----"
mkdir -p /app/logs
#chown -R nginx:nginx /app/logs		# Better not to chown for log dir

[ ! -e conf/nginx.conf-$NGINX_VERSION ] && {
echo "conf/nginx.conf-$NGINX_VERSION is not exist."
exit 1
}
/bin/cp -a conf/nginx.conf-$NGINX_VERSION $NGINX_LN_DIR/conf/nginx.conf

[ ! -d conf/extra ] && {
echo "conf/extra is not exist."
exit 1
}
/bin/cp -a conf/extra $NGINX_LN_DIR/conf/

$NGINX_LN_DIR/sbin/nginx -t
pkill nginx
sleep 2
$NGINX_LN_DIR/sbin/nginx
$NGINX_LN_DIR/sbin/nginx -s reload

echo "-----Step 04: Check nginx-----"
if [ `egrep "blog.zhangjamin.com|wiki.zhangjamin.com" /etc/hosts | wc -l` -lt 2 ];then
echo "127.0.0.1		bbs.zhangjamin.com blog.zhangjamin.com www.zhangjamin.com wiki.zhangjamin.com status.zhangjamin.com" \
>> /etc/hosts
fi

cd /var/html/
for n in `ls`; do echo "http://$n.zhangjamin.com" > $n/index.html; done

for n in `ls`;
do
cat > $n/jamin-test.php <<EOF
<?php
phpinfo();
?>
EOF
curl http://$n.zhangjamin.com/jamin-test.php
sleep 3
done

echo "OK!"




