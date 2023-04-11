# mysql-diagnostics.sh

 SETTINGS
 PLEASE SET VARIABLES BELOW
 
 RDSUSER requires at least a PROCESS PRIVILEGE
 
 It's advised to call this script as unpriviled user from cron. Please set proper permissions for STAT_DIR to allow that user to write files in that directory
 It's advised this script use the command:
 
	1. nc -zv <RDSHOST> <RDSPORT>
	2. netstat -ntp | grep mysql
	3. dig <RDSHOST>
	4. nslookup <RDSHOST>

