create spfile from pfile
/

alter system set enable_pluggable_database = false scope = spfile
/

shutdown abort

startup nomount

create database testdb
USER SYS IDENTIFIED BY testdbpw
USER SYSTEM IDENTIFIED BY testdbpw
controlfile reuse
logfile
group  1 ('/opt/oracle/oradata/testdb/redo/log01a.rdo', '/opt/oracle/oradata/testdb/redo/log01b.rdo') size 50M reuse,
group  2 ('/opt/oracle/oradata/testdb/redo/log02a.rdo', '/opt/oracle/oradata/testdb/redo/log02b.rdo') size 50M reuse,
group  3 ('/opt/oracle/oradata/testdb/redo/log03a.rdo', '/opt/oracle/oradata/testdb/redo/log03b.rdo') size 50M reuse
datafile '/opt/oracle/oradata/testdb/system01.dbf' size 250M reuse autoextend on maxsize 500M
sysaux datafile '/opt/oracle/oradata/testdb/sysaux01.dbf' size 100M reuse autoextend on maxsize 500M
undo tablespace undotbs datafile '/opt/oracle/oradata/testdb/undo01.dbf' size 100M reuse
DEFAULT TEMPORARY TABLESPACE temp 
TEMPFILE '/opt/oracle/oradata/testdb/temp.dbf' size 75M reuse
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
