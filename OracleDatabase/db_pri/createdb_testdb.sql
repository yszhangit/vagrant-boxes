create database testdb
controlfile reuse
logfile
group  1 ('/opt/oracle/oradata/testdb/redo/log01a.rdo', '/opt/oracle/oradata/testdb/redo/log01b.rdo') size 50M,
group  2 ('/opt/oracle/oradata/testdb/redo/log02a.rdo', '/opt/oracle/oradata/testdb/redo/log02b.rdo') size 50M,
group  3 ('/opt/oracle/oradata/testdb/redo/log03a.rdo', '/opt/oracle/oradata/testdb/redo/log03b.rdo') size 50M
datafile
	'/opt/oracle/oradata/testdb/system01.dbf' size 250M autoextend on maxsize 500M
sysaux datafile
	'/opt/oracle/oradata/testdb/sysaux01.dbf' size 100M autoextend on maxsize 500M
undo tablespace undotbs datafile
	'/opt/oracle/oradata/testdb/undo01.dbf' size 50M
DEFAULT TEMPORARY TABLESPACE temp 
TEMPFILE '/opt/oracle/oradata/testdb/temp.dbf' size 75M
CHARACTER SET AL32UTF8
NATIONAL CHARACTER SET AL16UTF16
EXTENT MANAGEMENT LOCAL
MAXLOGFILES 10
MAXLOGHISTORY 1
MAXDATAFILES 500
/

@$ORACLE_HOME/rdbms/admin/catalog.sql

@$ORACLE_HOME/rdbms/admin/catproc.sql

@$ORACLE_HOME/rdbms/admin/utlrp.sql

@$ORACLE_HOME/sqlplus/admin/pupbld.sql

-- alter user system identified by testdbpw

-- connect system/testdbpw

-- awr every 15min, keep 31 days
exec dbms_workload_repository.modify_snapshot_settings(interval => 15, retention => 44640) ;
