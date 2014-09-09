#!/bin/bash
# Usage: auto-mysql3307-backup
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
MYSQL_DUMP="${MYSQL_PATH}/mysqldump -u$MYUSER -p$MYPASS -S $MYSOCK -A -B --flush-logs --single-transaction -e"

${MYSQL_CMD} -e "flush tables with read lock;"
echo "-----Show master status-----" >> ${LOG_FILE}
${MYSQL_CMD} -e "show master status;" >> ${LOG_FILE}
${MYSQL_DUMP} | gzip > ${DATA_FILE}
mail -s "mysql master status" zhangjamin@163.com < ${LOG_FILE}
