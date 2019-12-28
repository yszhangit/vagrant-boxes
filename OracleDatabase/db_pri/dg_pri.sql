SHUTDOWN IMMEDIATE;
STARTUP MOUNT;

alter system set log_archive_dest_1='LOCATION=/opt/oracle/oradata/testdb/arch/' scope=spfile;
ALTER SYSTEM SET LOG_ARCHIVE_FORMAT='%t_%s_%r.arc' SCOPE=SPFILE;
ALTER SYSTEM SET LOG_ARCHIVE_MAX_PROCESSES=3

ALTER DATABASE ARCHIVELOG;
ALTER DATABASE FORCE LOGGING;

alter system set DB_UNIQUE_NAME=testdb_dga scope=spfile

ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(testdb_dga,testdb_dgb)';
ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=defer;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=testdb_dgb NOAFFIRM ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=testdb_dgb';
ALTER SYSTEM SET REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE SCOPE=SPFILE;
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;

ALTER DATABASE ADD STANDBY LOGFILE ('/opt/oracle/oradata/testdb/redo/standby_redo01.rdo') SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE ('/opt/oracle/oradata/testdb/redo/standby_redo02.rdo') SIZE 50M;
ALTER DATABASE ADD STANDBY LOGFILE ('/opt/oracle/oradata/testdb/redo/standby_redo03.rdo') SIZE 50M;


ALTER DATABASE FLASHBACK ON;

ALTER DATABASE OPEN;

create pfile='/tmp/primary.ora' from spfile;

-- backup before create standby control file
-- rman target /
-- configure channel device type disk format '/tmp/empty%d_DB_%u_%s_%p';
-- backup database;


ALTER DATABASE CREATE STANDBY CONTROLFILE AS '/tmp/standby.ctl';
