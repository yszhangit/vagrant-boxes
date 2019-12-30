# setup oracle database, inside of VM

# staging directory inside of VM(readonly)
STGDIR=/vagrant
ORADATA=/opt/oracle/oradata/testdb
ORACLE_HOME=/opt/oracle/product/12.1.0.2/dbhome_1

mkdir -p /opt/oracle/admin/testdb/adump

mkdir -p $ORADATA/ctl
mkdir -p $ORADATA/redo
mkdir -p $ORADATA/arch
mkdir -p $ORADATA/fra

cp -f $STGDIR/inittestdb.ora $ORACLE_HOME/dbs

# add *.enable_pluggable_database=true to init file to disable PDB

