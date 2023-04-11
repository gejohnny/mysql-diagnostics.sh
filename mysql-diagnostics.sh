#!/bin/sh

######################################################
#
# SETTINGS
# PLEASE SET VARIABLES BELOW
# 
# RDSUSER requires at least a PROCESS PRIVILEGE
# 
# It's advised to call this script as unpriviled user from cron. Please set proper permissions for STAT_DIR to allow that user to write files in that directory
# It's advised this script use the command:
#	nc -zv <RDSHOST> <RDSPORT>
#	netstat -ntp | grep mysql
#	dig <RDSHOST>
#	nslookup <RDSHOST>
#
#####################################################
#VARIABLES
#####################################################
RDSHOST=''
RDSPORT=''
RDSUSER=''
RDSPASSWORD=''
STAT_DIR="${HOME}/mysql_stats/"
######################################################
#DEFINE
######################################################
##Time stamp for log name
DATE=`date -u '+%Y-%m-%d-%H%M%S'`

##Check if command defined on $1 exists on host  
check_cmd_exist() {
	if ! type $1 >/dev/null
	then 
		echo "N"
	else
		echo "Y"
	fi
}

##Do some network related checks if previous mysql connection failed
check_conn() {
	if [ $? -ne 0 ]
	then
		if [ "`check_cmd_exist nc`" = "Y" ]
		then
			echo "`date -u '+%Y-%m-%d-%H%M%S'`:================START NC CONNECTION ERROR SECTION================"  2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
			nc -zv ${RDSHOST} ${RDSPORT} 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
			echo "`date -u '+%Y-%m-%d-%H%M%S'`:================END NC CONNECTION ERROR SECTION================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
		fi

		if [ `check_cmd_exist netstat` = "Y" ]
		then
		echo "`date -u '+%Y-%m-%d-%H%M%S'`:================START NETSTAT CONNECTION ERROR SECTION================"  2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
			netstat -ntp | grep mysql 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
		echo "`date -u '+%Y-%m-%d-%H%M%S'`:================END NETSTAT CONNECTION ERROR SECTION================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
		fi

		if [ `check_cmd_exist dig` = "Y" ]
		then
			echo "`date -u '+%Y-%m-%d-%H%M%S'`:================START DIG CONNECTION ERROR SECTION================"  2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
			dig ${RDSHOST} 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
			echo "`date -u '+%Y-%m-%d-%H%M%S'`:================END DIG CONNECTION ERROR SECTION================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
		elif [ `check_cmd_exist nslookup` = "Y" ]
		then
			echo "`date -u '+%Y-%m-%d-%H%M%S'`:================START NSLOOKUP CONNECTION ERROR SECTION================"  2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
			dig ${RDSHOST} 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
			echo "`date -u '+%Y-%m-%d-%H%M%S'`:================END NSLOOKUP CONNECTION ERROR SECTION================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
		fi
	fi
}
######################################################

######################################################
#MAIN
######################################################

##Create the log directory if not exists
mkdir -p ${STAT_DIR}

##Do the checks
if [ $? -eq 0 ]; then
	echo "`date -u '+%Y-%m-%d-%H%M%S'`:================FULL PROCESS LIST================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	mysql -u ${RDSUSER} --password=${RDSPASSWORD} -h ${RDSHOST} -e 'SHOW FULL PROCESSLIST;' 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	check_conn
	echo "`date -u '+%Y-%m-%d-%H%M%S'`:================INNODB STATUS================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	mysql -u ${RDSUSER} --password=${RDSPASSWORD} -h ${RDSHOST} -e 'SHOW ENGINE INNODB STATUS\G' 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	check_conn
	echo "`date -u '+%Y-%m-%d-%H%M%S'`:================INNODB MUTEX================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	mysql -u ${RDSUSER} --password=${RDSPASSWORD} -h ${RDSHOST} -e 'SHOW ENGINE INNODB MUTEX;' 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	check_conn
	echo "`date -u '+%Y-%m-%d-%H%M%S'`:================GLOBAL STATUS================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	mysql -u ${RDSUSER} --password=${RDSPASSWORD} -h ${RDSHOST} -e 'SHOW GLOBAL STATUS;' 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	check_conn
	echo "`date -u '+%Y-%m-%d-%H%M%S'`:================VARIABLES================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	mysql -u ${RDSUSER} --password=${RDSPASSWORD} -h ${RDSHOST} -e 'SHOW VARIABLES;' 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	check_conn
	echo "`date -u '+%Y-%m-%d-%H%M%S'`:================GLOBAL VARIABLES================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	mysql -u ${RDSUSER} --password=${RDSPASSWORD} -h ${RDSHOST} -e 'SHOW GLOBAL VARIABLES;' 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	check_conn
	echo "`date -u '+%Y-%m-%d-%H%M%S'`:================LOCKS================" 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	mysql -u ${RDSUSER} --password=${RDSPASSWORD} -h ${RDSHOST} -e 'SELECT trx_id, trx_state, trx_wait_started, trx_requested_lock_id, time_to_sec(timediff(now(),trx_started)) AS cq, lock_type, lock_table, lock_index, lock_data FROM information_schema.innodb_trx LEFT JOIN information_schema.innodb_locks ON trx_requested_lock_id=lock_id; ' 2>&1 | tee -a ${STAT_DIR}/${DATE}.output >/dev/null
	check_conn
else
	echo "DIRECTORY CREATING ERROR"
fi
######################################################
