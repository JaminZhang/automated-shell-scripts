#!/bin/bash
# Usage: auto-mysql3307-tables-backup
# Version: 1.2
# Author: Jamin Zhang
# Email: zhangjamin@163.com

# Init variables
WEEK=`date +%w`
DB_PWD="123456"
DB_PATH="/data/3307"
BACKUP_PATH="/server/backup"
INSTALL_DIR="/app/mysql/bin"
MYSQL_LOGIN="${INSTALL_DIR}/mysql -uroot -p${DB_PWD} -S ${DB_PATH}/mysql.sock"
MYSQL_DUMP="${INSTALL_DIR}/mysqldump -uroot -p${DB_PWD} -S ${DB_PATH}/mysql.sock -F -B -A --single-transaction | gzip"

BACKUP_SERVER="10.0.1.21"
LOCAL_IP=`grep IPADDR /etc/sysconfig/network-scripts/ifcfg-eth1 | awk -F = '{print $2}'`

# If week is 6 then backup another file.
if [ ${WEEK} -eq 6 ] 
then
	find ${BACKUP_PATH}/ -mtime +7 -type d -iname "*_?" | xargs rm -rf			
#	rm -f ${BACKUP_PATH}/mysql3307_$(date --date="7 days ago" +%w_%Y%m%d).sql.*
	log="${BACKUP_PATH}/mysql3307_$(date +%w__%Y%m%d%H%M%S).sql.log"
    datadir="${BACKUP_PATH}/$(date +%w_%Y%m%d%H%M%S)"							
else
	log="${BACKUP_PATH}/mysql3307_${WEEK}.sql.log"
    datadir="${BACKUP_PATH}/${WEEK}"
fi

# Stop slave for backup
echo "stop slave SQL_THREAD;" | ${MYSQL_LOGIN}

echo "#####`date +%Y%m%d%H%M%S-%w`#####" >> $log
echo -e "master:info:" >> $log
sed -n '2,3p' ${DB_PATH}/data/master.info >> $log
echo -e "show slave status:" >> $log
echo "show slave status\G" | ${MYSQL_LOGIN} | egrep "Master_Log_File|Read_Master_Log_Pos" | sed -n '1,2p' | \
awk -F": " '{print $2}' >> $log
echo -e "#####Start Pos#####\n" >> $log
cd ${INSTALL_DIR}
#${MYSQL_DUMP} > $data
# For loop backup tables 
for dbname in `${MYSQL_LOGIN} -e "show databases" | sed '1d'`
do
	mkdir -p ${datadir}/${dbname}_${WEEK} &&
	cd ${datadir}/${dbname}_${WEEK}
	echo -e "#####${dbname}--Start_Time:`date`#####" >> ${datadir}/fenbiao_${WEEK}.log
		for tablename in `${MYSQL_LOGIN} ${dbname} -e "show tables" | sed '1d'`
		do
			cd ${INSTALL_DIR}
			echo -e "#####${dbname}-${tablename}--Start_Time:`date`#####" >> ${datadir}/fenbiao_${WEEK}.log
			${MYSQL_DUMP} ${dbname} ${tablename} | gzip > ${datadir}/${dbname}_$WEEK/${dbname}_${tablename}.sql.gz
			echo >> ${datadir}/fenbiao_${WEEK}.log			# print 1 blank line
		done
	echo -e "#####${dbname}--Stop_Time:`date`#####" >> ${datadir}/fenbiao_${WEEK}.log
	echo >> ${datadir}/fenbiao_${WEEK}.log;echo >> ${datadir}/fenbiao_${WEEK}.log	# print 2 blank lines
	du -sh ${BACKUP_PATH}/${WEEK}/${dbname}_${WEEK}/ >>  ${datadir}/fenbiao_${WEEK}.log 	# When week is 6, there is a problem!!!
	echo >> ${datadir}/fenbiao_${WEEK}.log;echo >> ${datadir}/fenbiao_${WEEK}.log	# print 2 blank lines
done


echo "#####`date +%Y%m%d%H%M%S-%w`#####" >> $log
echo -e "master:info:" >> $log
sed -n '2,3p' ${DB_PATH}/data/master.info >> $log
echo -e "show slave status:" >> $log
echo "show slave status\G" | ${MYSQL_LOGIN} | egrep "Master_Log_File|Read_Master_Log_Pos" | sed -n '1,2p' | \
awk -F": " '{print $2}' >> $log
echo -e "#####End Pos#####\n" >> $log

echo "start slave SQL_THREAD;" | ${MYSQL_LOGIN}

mail -s "backup log info" zhangjamin@163.com < $log

# Rsync all data to bakcup server
rsync -avz --progress ${BACKUP_PATH}/ rsync_backup@${BACKUP_SERVER}::backup/${LOCAL_IP} --password-file=/etc/rsync.password > /dev/null 2>&1

