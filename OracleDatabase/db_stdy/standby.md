# protection mode:

- max perf: async/noaffirm
- max protection: sync/affirm
- max availability: sync/affirm or noaffirm, sync/noaffirm is fastSync.

when standby is unavaliable, "max perf" continue, "max aval" continue, "max prot" shutdown

`ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE {AVAILABILITY | PERFORMANCE | PROTECTION};` can change mode 

or change `log_archive_dest_n`

`alter system set log_archive_dest_2='SERVICE=testdb_dgb NOAFFIRM SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=testdb_dgb scope=both'`

to check mode 'select protection_mode,protection_level from v$database`

# create standby

## pre
* create directories
* copy standby controlfile to location specified in init file
* copy init file(spfile), make necessary changes

    make sure db_unique_name is changed

    `alter system set DB_UNIQUE_NAME=testdb_dga scope=spfile`
* startup mount

## manually create standby
* rman restore
* add standby log in standby
* enable dest_2 on primary
* start recovery
`ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;`


## rman duplicate

`rman target sys/testdbpw@testdb_dga auxiliary sys/testdbpw@testdb_dgb`

```
DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE
  DORECOVER
  SPFILE
    SET db_unique_name='testdb_dgb' COMMENT 'testdb standby'
    SET LOG_ARCHIVE_DEST_2='SERVICE=testdb_dga ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=test_dga'
  NOFILENAMECHECK;
```

# manual switch over
## primary
```
ALTER DATABASE COMMIT TO SWITCHOVER TO STANDBY;
startup nomount
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

```

## standby
```
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
alter database open;
```
for standby that never run as primary, there's no online redo log, restart instance
```
shutdown immeidate
startup
```
```
