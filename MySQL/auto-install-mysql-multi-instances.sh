#!/bin/bash
# Usage: auto-install-mysql-multi-instances
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

. /etc/init.d/functions

MYSQL_DIR="/app/mysql"
MYSQL_CMD_DIR="/app/mysql/bin"
INSTANCE_CONF_PATH="/server/scripts/mysqlconf"
MYSQL_DATA="/data"
PASSWD="123456"

[ ! -d ${MYSQL_CMD_DIR} ] && exit 1
[ ! -d ${INSTANCE_CONF_PATH} ] && exit 1
[ ! -d ${MYSQL_DIR}/data ] && mkdir -p ${MYSQL_DIR}/data
echo "export PATH=$PATH:${MYSQL_CMD_DIR}" >> /etc/profile
source /etc/profile

for PORT in 3306 3307
do
	mkdir -p ${MYSQL_DATA}/$PORT/data
	\cp ${INSTANCE_CONF_PATH}/my.cnf ${MYSQL_DATA}/$PORT/
	\cp ${INSTANCE_CONF_PATH}/mysql ${MYSQL_DATA}/$PORT/

	sed -i "s/3306/$PORT/g" ${MYSQL_DATA}/$PORT/my.cnf
	sed -i "s/3306/$PORT/g" ${MYSQL_DATA}/$PORT/mysql
	sed -i "s/^server-id = 1/server-id = `echo $PORT | cut -c 4-`/g" ${MYSQL_DATA}/$PORT/my.cnf
	chown -R mysql:mysql ${MYSQL_DATA}/$PORT
	chmod 700 ${MYSQL_DATA}/$PORT/mysql
	${MYSQL_CMD_DIR}/mysql_install_db --datadir=${MYSQL_DATA}/$PORT/data --user=mysql \
>> /tmp/mysql_multi_instances.log
	${MYSQL_DATA}/$PORT/mysql start
	sleep 5

	if [ `netstat -lnt | grep "$PORT" | wc -l` -eq 1 ];then
		action "mysql $PORT is started." /bin/true
	else
		action "mysql $PORT is started." /bin/false
	fi
		
	[ `netstat -lnt | grep "$PORT" | wc -l` -eq 1 ] && \
	echo "# mysql multi instances $PORT" >> /etc/rc.local
	echo "${MYSQL_DATA}/$PORT/mysql start" >> /etc/rc.local 
	${MYSQL_CMD_DIR}/mysqladmin -u root -S ${MYSQL_DATA}/$PORT/mysql.sock password "$PASSWD"
	sed -i "s/mysql_pwd=""/mysql_pwd="$PASSWD"/g" ${MYSQL_DATA}/$PORT/mysql
#	if [ $? -eq 0 ];then
#	${MYSQL_CMD_DIR}/mysql -u root -p"$PASSWD" -S ${MYSQL_DATA}/$PORT/mysql.sock -e "drop user ''@localhost;"
#	${MYSQL_CMD_DIR}/mysql -u root -p"$PASSWD" -S ${MYSQL_DATA}/$PORT/mysql.sock -e "drop user ''@`hostname`;"
#	${MYSQL_CMD_DIR}/mysql -u root -p"$PASSWD" -S ${MYSQL_DATA}/$PORT/mysql.sock -e "drop user 'root'@`hostname`;"
#	fi
done
echo
echo "mysql multi instances is configured successfully."
