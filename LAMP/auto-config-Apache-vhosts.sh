#!/bin/bash
# Usage: auto-install-Apache-vhosts Sample
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

SOFT_DIR="/home/jamin/soft"
APACHE_VERSION="2.2.22"
APACHE_INSTALL_DIR="/app/apache-${APACHE_VERSION}"
APACHE_LN_DIR="/app/apache"
DocumentRoot="/var/html"

echo "-----Step 01: Make site dir-----"
for dir in www blog bbs wiki
do
	mkdir -p $DocumentRoot/$dir
	echo "$dir" >> $DocumentRoot/$dir/index.html
done

echo "-----Step 02: Config httpd.conf-----"
/bin/cp $APACHE_INSTALL_DIR/conf/httpd.conf $APACHE_INSTALL_DIR/conf/httpd.conf.ori
sed -i 's!#Include conf/extra/httpd-vhosts.conf!Include conf/extra/httpd-vhosts.conf!' $APACHE_INSTALL_DIR/conf/httpd.conf


echo "-----Step 03: Config site dir access-----"
cat >> $APACHE_INSTALL_DIR/conf/httpd.conf << EOF
<Directory "$DocumentRoot">
	Options -Indexes FollowSymLinks
	AllowOverride None
	Order allow,deny
	Allow from all
</Directory>
EOF

echo "-----Step 04: Config httpd-vhosts.conf-----"
cat > $APACHE_INSTALL_DIR/conf/extra/httpd-vhosts.conf << EOF
NameVirtualHost *:80
<VirtualHost *:80>
	ServerAdmin	zhangjamin@163.com
	DocumentRoot	"$DocumentRoot/www"
	ServerName	www.zhangjamin.com
	ErrorLog	"|/usr/local/sbin/cronolog /app/logs/www_error_%Y%m%d.log"
	CustomLog	"|/usr/local/sbin/cronolog /app/logs/www_access_%Y%m%d.log"	combined
	ExpiresActive	on
	ExpiresDefault	"access plus 12 month"
	ExpiresByType	text/html	"access plus 12 month"
	ExpiresByType	text/css	"access plus 12 month"
	ExpiresByType	image/gif	"access plus 12 month"
	ExpiresByType	image/jpeg	"access plus 12 month"
	ExpiresByType	image/jpg	"access plus 12 month"
	ExpiresByType	image/png	"access plus 12 month"	
	ExpiresByType	application/x-shockwave-flash	"access plus 12 month"	
	ExpiresByType	application/x-javascript	"access plus 12 month"	
	ExpiresByType	video/x-flv	"access plus 12 month"
	<ifmodule mod_deflate.c>
		DeflateCompressionLevel	9
		SetOutputFilter	DEFLATE
		AddOutputFilterByType	DEFLATE	text/html text/plain text/xml text/css
		AddOutputFilterByType	DEFLATE	application/javascript
	</ifmodule>
</VirtualHost>

<VirtualHost *:80>
	ServerAdmin	zhangjamin@163.com
	DocumentRoot	"$DocumentRoot/blog"
	ServerName	blog.zhangjamin.com
	ErrorLog	"|/usr/local/sbin/cronolog /app/logs/blog_error_%Y%m%d.log"
	CustomLog	"|/usr/local/sbin/cronolog /app/logs/blog_access_%Y%m%d.log"	combined
	ExpiresActive	on
	ExpiresDefault	"access plus 12 month"
	ExpiresByType	text/html	"access plus 12 month"
	ExpiresByType	text/css	"access plus 12 month"
	ExpiresByType	image/gif	"access plus 12 month"
	ExpiresByType	image/jpeg	"access plus 12 month"
	ExpiresByType	image/jpg	"access plus 12 month"
	ExpiresByType	image/png	"access plus 12 month"	
	ExpiresByType	application/x-shockwave-flash	"access plus 12 month"	
	ExpiresByType	application/x-javascript	"access plus 12 month"	
	ExpiresByType	video/x-flv	"access plus 12 month"
	<ifmodule mod_deflate.c>
		DeflateCompressionLevel	9
		SetOutputFilter	DEFLATE
		AddOutputFilterByType	DEFLATE	text/html text/plain text/xml text/css
		AddOutputFilterByType	DEFLATE	application/javascript
	</ifmodule>
</VirtualHost>

<VirtualHost *:80>
	ServerAdmin	zhangjamin@163.com
	DocumentRoot	"$DocumentRoot/bbs"
	ServerName	bbs.zhangjamin.com
	ErrorLog	"|/usr/local/sbin/cronolog /app/logs/bbs_error_%Y%m%d.log"
	CustomLog	"|/usr/local/sbin/cronolog /app/logs/bbs_access_%Y%m%d.log"	combined
	ExpiresActive	on
	ExpiresDefault	"access plus 12 month"
	ExpiresByType	text/html	"access plus 12 month"
	ExpiresByType	text/css	"access plus 12 month"
	ExpiresByType	image/gif	"access plus 12 month"
	ExpiresByType	image/jpeg	"access plus 12 month"
	ExpiresByType	image/jpg	"access plus 12 month"
	ExpiresByType	image/png	"access plus 12 month"	
	ExpiresByType	application/x-shockwave-flash	"access plus 12 month"	
	ExpiresByType	application/x-javascript	"access plus 12 month"	
	ExpiresByType	video/x-flv	"access plus 12 month"
	<ifmodule mod_deflate.c>
		DeflateCompressionLevel	9
		SetOutputFilter	DEFLATE
		AddOutputFilterByType	DEFLATE	text/html text/plain text/xml text/css
		AddOutputFilterByType	DEFLATE	application/javascript
	</ifmodule>
</VirtualHost>

<VirtualHost *:80>
	ServerAdmin	zhangjamin@163.com
	DocumentRoot	"$DocumentRoot/wiki"
	ServerName	wiki.zhangjamin.com
	ErrorLog	"|/usr/local/sbin/cronolog /app/logs/wiki_error_%Y%m%d.log"
	CustomLog	"|/usr/local/sbin/cronolog /app/logs/wiki_access_%Y%m%d.log"	combined
	ExpiresActive	on
	ExpiresDefault	"access plus 12 month"
	ExpiresByType	text/html	"access plus 12 month"
	ExpiresByType	text/css	"access plus 12 month"
	ExpiresByType	image/gif	"access plus 12 month"
	ExpiresByType	image/jpeg	"access plus 12 month"
	ExpiresByType	image/jpg	"access plus 12 month"
	ExpiresByType	image/png	"access plus 12 month"	
	ExpiresByType	application/x-shockwave-flash	"access plus 12 month"	
	ExpiresByType	application/x-javascript	"access plus 12 month"	
	ExpiresByType	video/x-flv	"access plus 12 month"
	<ifmodule mod_deflate.c>
		DeflateCompressionLevel	9
		SetOutputFilter	DEFLATE
		AddOutputFilterByType	DEFLATE	text/html text/plain text/xml text/css
		AddOutputFilterByType	DEFLATE	application/javascript
	</ifmodule>
</VirtualHost>	
EOF
