#!/bin/bash

export JAVA_HOME=/usr

echo "Starting SSHD ..."
service ssh start
ssh-keyscan -H 0.0.0.0 >> ~/.ssh/known_hosts
ssh-keyscan -H localhost >> ~/.ssh/known_hosts
ssh-keyscan -H 127.0.0.1 >> ~/.ssh/known_hosts

HDFS_EXISTS=1
if [ ! -f /hadoop/hdfs/namenode/current/VERSION ]; then
    echo "Formatting HDFS ..."
    /opt/hadoop/bin/hdfs namenode -format
    HDFS_EXISTS=0
fi


echo "Starting HDFS ..."
/opt/hadoop/sbin/start-dfs.sh

if [ $HDFS_EXISTS -eq 0 ]; then
    echo "Creating HDFS folder structure ..."
    /opt/hadoop/bin/hdfs dfs -mkdir /tmp
    /opt/hadoop/bin/hdfs dfs -mkdir /apps
    /opt/hadoop/bin/hdfs dfs -mkdir /apps/spark
    /opt/hadoop/bin/hdfs dfs -mkdir /user
    /opt/hadoop/bin/hdfs dfs -chmod 755 /user
    /opt/hadoop/bin/hdfs dfs -mkdir /user/oozie
    /opt/hadoop/bin/hdfs dfs -chown oozie:oozie /user/oozie
    /opt/hadoop/bin/hdfs dfs -chmod 755 /user
    /opt/hadoop/bin/hdfs dfs -chmod 755 /user/oozie
fi


echo "Starting YARN ..."
/opt/hadoop/sbin/start-yarn.sh


echo "Starting HBase"
su -l -c "/opt/hbase/bin/start-hbase.sh"
/opt/hbase/bin/hbase-daemon.sh start rest -p 16060 --infoport 16070

echo "Done"

/opt/hadoop/bin/hdfs dfs -ls /user/oozie/share/lib
if [ $? -eq 1 ]; then
    echo "Preparing Oozie"
    su -l -c "cd /opt/oozie && bin/oozie-setup.sh sharelib create -fs hdfs://localhost:8020  -locallib oozie-sharelib-4.3.1.tar.gz" oozie
fi


echo "Starting Oozie"
su -l -c "/opt/oozie/bin/oozied.sh start" oozie

echo "Done"

sleep infinity
