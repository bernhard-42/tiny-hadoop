#!/bin/bash

export JAVA_HOME=/usr

echo "Starting SSHD ..."
service ssh start

echo "Setting up ssh access"
sudo -u hdfs ssh-keyscan -H 0.0.0.0 >> /home/hdfs/.ssh/known_hosts
sudo -u hdfs ssh-keyscan -H localhost >> /home/hdfs/.ssh/known_hosts
sudo -u hdfs ssh-keyscan -H 127.0.0.1 >> /home/hdfs/.ssh/known_hosts

HDFS_EXISTS=1
if [ ! -f /hadoop/hdfs/namenode/current/VERSION ]; then
    echo "Formatting HDFS ..."
    sudo -u hdfs /opt/hadoop/bin/hdfs namenode -format
    HDFS_EXISTS=0
fi

echo "Starting HDFS ..."
sudo -u hdfs /opt/hadoop/sbin/start-dfs.sh

if [ $HDFS_EXISTS -eq 0 ]; then
    echo "Creating HDFS folder structure ..."
    sudo -u hdfs kinit -k -t /etc/security/keytabs/hadoop.keytab hdfs/kerberos-hadoop@ACME.LOCALDOMAIN
    sudo -u hdfs /opt/hadoop/bin/hdfs dfs -mkdir /tmp
    sudo -u hdfs /opt/hadoop/bin/hdfs dfs -mkdir /apps
    sudo -u hdfs /opt/hadoop/bin/hdfs dfs -mkdir /apps/spark
    sudo -u hdfs /opt/hadoop/bin/hdfs dfs -mkdir /user
    sudo -u hdfs /opt/hadoop/bin/hdfs dfs -chown -R hdfs:hadoop /
    sudo -u hdfs /opt/hadoop/bin/hdfs dfs -chmod 755 /user
fi

sleep infinity
