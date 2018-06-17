FROM ubuntu:16.04

ARG HADOOP_VERSION
ARG SPARK_VERSION
ARG HBASE_VERSION

# Installation Hadoop, Spark and HBase
RUN apt-get update && \
    apt-get install -y default-jdk wget vim-tiny less openssh-client openssh-server net-tools python zip unzip && \
    cd /tmp && \
    echo "=== DOWNLOADS ===" && \
    wget http://www-eu.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    wget http://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    wget http://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz && \
    wget https://github.com/patric-r/jvmtop/releases/download/0.8.0/jvmtop-0.8.0.tar.gz && \
    cd /opt && \
    echo "=== HADOOP ===" && \
    tar -zxvf /tmp/hadoop-${HADOOP_VERSION}.tar.gz && \
    rm -fr /opt/hadoop-${HADOOP_VERSION}/share/doc/ && \
    mv hadoop-${HADOOP_VERSION} hadoop && \
    echo "=== SPARK ===" && \
    tar -zxvf /tmp/spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    mv spark-${SPARK_VERSION}-bin-without-hadoop spark && \
    echo "=== HBASE ===" && \
    tar -zxvf /tmp/hbase-${HBASE_VERSION}-bin.tar.gz && \
    mv hbase-${HBASE_VERSION} hbase && \
    echo "=== JVMTOP ===" && \
    mkdir /opt/jvmtop && \
    cd  /opt/jvmtop && \
    tar -zxvf /tmp/jvmtop-0.8.0.tar.gz && \
    chmod a+x jvmtop.sh && \
    echo "=== CLEAN UP ===" && \
    chown -R root:root /opt && \
    rm /tmp/*.tar.gz

# SSH Configuration
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    echo "JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64" >> /etc/environment && \
    echo "export SPARK_DIST_CLASSPATH=$(JAVA_HOME=/usr /opt/hadoop/bin/hadoop classpath)" > /opt/spark/conf/spark-env.sh && \
    echo hadoop-${HADOOP_VERSION} >> /opt/hadoop-version.txt && \
    echo spark-${SPARK_VERSION} >> /opt/hadoop-version.txt && \
    echo hbase-${HBASE_VERSION} >> /opt/hadoop-version.txt

ADD container_root /

CMD /run.sh
