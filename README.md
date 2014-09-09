automated-shell-scripts
=======================

automated shell scripts used in the work

There are some automated shell scripts that written by me and used in my work.
The automated shell scripts are about deploying and configuring common services.

这里是我编写的并且在我的工作中使用的一些自动化Shell脚本。
这些自动化Shell脚本是关于部署和配置常用服务的。

以下是大概目录。


目录
-----------------------------------
###Linux系统安装后自动初始化优化配置脚本
	System-Init-Opti.sh
###Linux系统安装后自动安装监控客户端配置脚本
	auto-install-nagios-client.sh
	auto-install-snmp-client.sh
###SSH免密钥批量分发管理服本	
	01.dispatch-sshkey.sh	
	dispatch-sshkey.exp	
	02.dispatch-file.sh	
###Rsync自动化安装部署配置脚本	
	01.auto-install-Rsync-server.sh	
	02.auto-install-Rsync-client.sh	
###MySQL环境自动化安装部署配置及数据备份脚本	
	auto-install-mysql.sh	
	auto-install-mysql-multi-instances.sh	
	auto-mysql3306-backup.sh	
	auto-mysql3306-slave.sh	
	auto-mysql3307-slave.sh	
	auto-mysql3307-backup.sh	
	auto-mysql3307-full-backup.sh	
	auto-mysql3307-tables-backup.sh	
	auto-install-Memcached.sh	
###LAMP环境自动化安装部署配置脚本	
	01.auto-install-Apache.sh	
	02.auto-install-php.sh	
	03.auto-install-php-ext.sh	
	04.auto-config-Apache-vhosts.sh	
###LNMP环境自动化安装部署配置脚本	
	01.auto-install-Nginx.sh		
	02.auto-install-nginx-php-fastcgi.sh	
	03.auto-install-nginx-php-ext.sh	
	04.auto-config-nginx-php.sh	
	cut-nginx-log.sh	
###LVS+Keepalived自动化安装部署配置脚本	
	auto-install-lvs.sh	
	ipvs-rs-config.sh	
###Ngios+Cacti服务器自动化安装部署配置脚本	
	auto-install-nagios-server.sh	
	auto-install-nagios-client.sh	
	create-nagios-hosts.sh	
	create-nagios-hostgroup.sh	
	production-nagios-service.sh	
	production-nagios-check-url.sh	
	auto-install-cacti-server.sh	
	auto-install-snmp-client.sh	
###服务器重要配置数据自动化备份脚本	
	backup-all-config.sh	
