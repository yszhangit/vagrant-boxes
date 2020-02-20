### enable broker on both primary and standby
`ALTER SYSTEM SET dg_broker_start=true;`

### remove log_archive_dest_n configuration

`alter system set log_archive_dest_2=''`

### register dg_listener

`netca` and `netmgr` doenst have option to add static service to SID_LIST to listener.ora anymore.

use dynamic service registration, LISTENER is added by default, only need to add if there are more listeners., use `lsnrctl status` to verify service is listed.

*when listener is up*, register service with *TNSNAME*
```
ALTER SYSTEM SET local_listener=testdb_dga SCOPE=BOTH
```

### add to DG listener as format "db_unique_name_DGMGRL"
*this step seems not needed, 12.1 doc doesnt have this step*
```
      (GLOBAL_DBNAME = testdb_dgb_DGMGRL)
```
login to both database as sysdba using tnsname


### create broker configuration
```
dgmgrl sys/testdbpw@testdb_dga

rem: create configure
create configuration dg_conf_1 as primary database is testdb_dga connect identifier is testdb_dga;

rem: add standby, this will be max perf by default
add database testdb_dgb as connect identifier is testdb_dgb maintained as physical;

rem: change to sync and to log transport
EDIT DATABASE 'testdb_dgb' SET PROPERTY 'LogXptMode'='SYNC';

rem: change protection mode, otherwise "show configuation" will show warning
EDIT CONFIGURATION SET PROTECTION MODE AS MAXAVAILABILITY;

rem: verify status
enable configuration;
show configuration;

```
### other tasks

```
rem: show database status
show database testdb_dga

rem: more detail stats and configuration
show database testdb_dgb

rem: suspend log transport
EDIT CONFIGURATION SET PROTECTION MODE AS MAXPERFORMANCE;
edit database testdb_dga set state='TRANSPORT-OFF';
rem: resume
edit database testdb_dga set state='TRANSPORT-ON';
EDIT CONFIGURATION SET PROTECTION MODE AS MAXAVAILABILITY;

rem: switch over
validate database testdb_dga
switchover to testdb_dgb

```
