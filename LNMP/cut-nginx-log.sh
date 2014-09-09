#!/bin/bash
# Usage: cut-nginx-log
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

NGINX_VERSION="1.4.7"
NGINX_INSTALL_DIR="/app/nginx-$NGINX_VERSION"
NGINX_LN_DIR="/app/nginx"
NGINX_LOGS="/app/logs"

DATE=`date +%Y%m%d`
DATE_3_AGO=`date +%Y%m%d -d "3 days ago"`

cd /tmp
[ -d $NGINX_LOGS ] && cd $NGINX_LOGS || exit 1

for LOG_NAME in `ls *access.log | awk -F . '{print $1}'`
do
	/bin/mv	$LOG_NAME.access.log ${LOG_NAME}.access.log-${DATE}
done

$NGINX_LN_DIR/sbin/nginx -s reload

LOGS_3_AGO=`ls -l *.access.log-${DATE_3_AGO} | wc -l`
[ ${LOGS_3_AGO} -gt 0 ] && {
for LOG_NAME in `ls *access.log | awk -F . '{print $1}'`
do
	tar czf ${LOG_NAME}-${DATE_3_AGO}.access.tar.gz ./${LOG_NAME}.access.log-${DATE_3_AGO} && rm -f ${LOG_NAME}.access.log-${DATE_3_AGO}
done
}
# rsync log.tar.gz to backup server
# find /app/logs -name "*.tar.gz" -mtime +7 | xargs rm -f

