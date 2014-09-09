#!/bin/bash
# Usage: auto-mysql3307-slave
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com


MYUSER="root"
MYPASS="123456"
MYSOCK="/data/3307/mysql.sock"

MAIN_PATH="/server/backup"
DATA_PATH="/server/backup"
LOG_FILE="${DATA_PATH}/mysql3307_logs_`date +%F`.log"
DATA_FILE="${DATA_PATH}/mysql3307_backup_`date +%F`.sql.gz"

MYSQL_PATH="/app/mysql/bin"
MYSQL_CMD="${MYSQL_PATH}/mysql -u$MYUSER -p$MYPASS -S $MYSOCK"

# Recover
cd ${DATA_PATH} && \
gzip -d mysql3307_backup_`date +%F`.sql.gz
${MYSQL_CMD} < mysql3307_backup_`date +%F`.sql

# Config slave
cat | ${MYSQL_CMD} << EOF
CHANGE MASTER TO
MASTER_HOST='10.0.1.14',
MASTER_PORT=3307,
MASTER_USER='rep',
MASTER_PASSWORD='oldboy123',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=244;
EOF

# Start slave
${MYSQL_CMD} -e "start slave;"

${MYSQL_CMD} -e "show slave status\G" | egrep "IO_Running|SQL_Running" >> ${LOG_FILE}

mail -s "mysql slave config result" zhangjamin@163.com < ${LOG_FILE}
