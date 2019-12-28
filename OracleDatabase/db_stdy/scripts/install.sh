#!/bin/bash
#
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
# 
# Since: January, 2018
# Author: gerald.venzl@oracle.com
# Description: Installs Oracle database software
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

# Abort on any error
set -e

echo 'INSTALLER: Started up'

# get up to date
yum upgrade -y

echo 'INSTALLER: System updated'

# fix locale warning
yum reinstall -y glibc-common
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

echo 'INSTALLER: Locale set'

# set system time zone
sudo timedatectl set-timezone $SYSTEM_TIMEZONE
echo "INSTALLER: System time zone set to $SYSTEM_TIMEZONE"

# Install Oracle Database prereq and openssl packages
yum install -y oracle-rdbms-server-12cR1-preinstall openssl

echo 'INSTALLER: Oracle preinstall and openssl complete'

# create directories
mkdir -p $ORACLE_BASE && \
chown oracle:oinstall -R $ORACLE_BASE && \
mkdir -p /u01/app && \
ln -s $ORACLE_BASE /u01/app/oracle

echo 'INSTALLER: Oracle directories created'

# set environment variables
echo "export ORACLE_BASE=$ORACLE_BASE" >> /home/oracle/.bashrc && \
echo "export ORACLE_HOME=$ORACLE_HOME" >> /home/oracle/.bashrc && \
echo "export ORACLE_SID=$ORACLE_SID" >> /home/oracle/.bashrc   && \
echo "export PATH=\$PATH:\$ORACLE_HOME/bin" >> /home/oracle/.bashrc

echo 'INSTALLER: Environment variables set'

# Install Oracle

case "$ORACLE_EDITION" in
  "EE")
    unzip '/vagrant/linuxamd64_12102_database_?of2.zip' -d /tmp
    ;;
  "SE2")
    unzip '/vagrant/linuxamd64_12102_database_se2_?of2.zip' -d /tmp
    ;;
  *)
    echo "INSTALLER: Invalid ORACLE_EDITION $ORACLE_EDITION. Must be EE or SE2. Exiting."
    exit 1
    ;;
esac

cp /vagrant/ora-response/db_install.rsp.tmpl /tmp/db_install.rsp
sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" /tmp/db_install.rsp && \
sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" /tmp/db_install.rsp && \
sed -i -e "s|###ORACLE_EDITION###|$ORACLE_EDITION|g" /tmp/db_install.rsp
su -l oracle -c "yes | /tmp/database/runInstaller -silent -showProgress -ignorePrereq -waitforcompletion -responseFile /tmp/db_install.rsp"
$ORACLE_BASE/oraInventory/orainstRoot.sh
$ORACLE_HOME/root.sh
# some files in the installer zips are extracted without write permissions
chmod -R u+w /tmp/database && \
rm -rf /tmp/database
rm /tmp/db_install.rsp

echo 'INSTALLER: Oracle software installed'

# create sqlnet.ora, listener.ora and tnsnames.ora
su -l oracle -c "mkdir -p $ORACLE_HOME/network/admin"
su -l oracle -c "echo 'NAME.DIRECTORY_PATH= (TNSNAMES, EZCONNECT, HOSTNAME)' > $ORACLE_HOME/network/admin/sqlnet.ora"

# Listener.ora
su -l oracle -c "echo 'LISTENER = 
(DESCRIPTION_LIST = 
  (DESCRIPTION = 
    (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1)) 
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) 
  ) 
) 

DEDICATED_THROUGH_BROKER_LISTENER=ON
DIAG_ADR_ENABLED = off
' > $ORACLE_HOME/network/admin/listener.ora"

su -l oracle -c "echo '$ORACLE_SID=localhost:1521/$ORACLE_SID' > $ORACLE_HOME/network/admin/tnsnames.ora"
su -l oracle -c "echo '$ORACLE_PDB= 
(DESCRIPTION = 
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = $ORACLE_PDB)
  )
)' >> $ORACLE_HOME/network/admin/tnsnames.ora"

# Start LISTENER
su -l oracle -c "lsnrctl start"

echo 'INSTALLER: Listener created'
