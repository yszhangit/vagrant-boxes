create database testdb
controlfile 
logfile
group  1 ('/opt/oracle/oradata/testdb/redo/log01a.rdo', '/opt/oracle/oradata/testdb/redo/log01b.rdo') size 50M,
group  2 ('/opt/oracle/oradata/testdb/redo/log02a.rdo', '/opt/oracle/oradata/testdb/redo/log02b.rdo') size 50M,
group  3 ('/opt/oracle/oradata/testdb/redo/log03a.rdo', '/opt/oracle/oradata/testdb/redo/log03b.rdo') size 50M
datafile
	'/opt/oracle/oradata/testdb/system01.dbf' size 250M autoextend on maxsize 500M
sysaux datafile
	'/opt/oracle/oradata/testdb/sysaux01.dbf' size 100M autoextend on maxsize 500M
undo tablespace undo datafile
database '/opt/oracle/oradata/testdb/undo01.dbf' size 50M
DEFAULT TEMPORARY TABLESPACE temp 
TEMPFILE '/opt/oracle/oradata/testdb/temp.dbf' size 75M
EXTENT MANAGEMENT LOCAL
MAXLOGFILES 10
MAXLOGHISTORY 1
MAXDATAFILES 500
/
