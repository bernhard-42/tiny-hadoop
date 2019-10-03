FROM ubuntu:18.04

ARG HADOOP_VERSION
ARG SPARK_VERSION

# Install system libraries
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget vim-tiny less openssh-client openssh-server net-tools python sudo zip unzip

# Create hdfs user
RUN groupadd -g 1000 hadoop && \
    useradd -g 1000 -u 1000 -r hdfs -d /home/hdfs && \
    mkdir /home/hdfs && \
    chown hdfs:hadoop /home/hdfs && \
    chmod 700 /home/hdfs

USER hdfs

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

USER root

# Install jvmtop
RUN cd /opt && \
    wget https://github.com/patric-r/jvmtop/releases/download/0.8.0/jvmtop-0.8.0.tar.gz && \
    mkdir jvmtop && \
    cd jvmtop && \
    tar -zxvf ../jvmtop-0.8.0.tar.gz && \
    chmod a+x jvmtop.sh && \
    rm ../*.tar.gz

# Install Spark
RUN cd /opt && \
    wget http://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    tar -zxvf spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    mv spark-${SPARK_VERSION}-bin-without-hadoop spark && \
    echo spark-${SPARK_VERSION} >> /opt/hadoop-version.txt && \
    rm *.tgz

# Install HDFS
RUN cd /opt && \
    wget http://www-eu.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -zxvf hadoop-${HADOOP_VERSION}.tar.gz && \
    rm -fr hadoop-${HADOOP_VERSION}/share/doc/ && \
    mv hadoop-${HADOOP_VERSION} hadoop && \
    chown -R hdfs:hadoop /opt/hadoop/ && \
    mkdir -p /var/run/hadoop/ && \
    chown -R hdfs:hadoop /var/run/hadoop  && \
    echo hadoop-${HADOOP_VERSION} >> /opt/hadoop-version.txt && \
    rm *.tar.gz

# Configuration
RUN echo "JAVA_HOME=/usr" >> /etc/environment && \
    mkdir -p /var/run/hadoop /var/run/spark && \
    sed -i 's:^export HADOOP_PID_DIR=.*:export HADOOP_PID_DIR=/var/run/hadoop:' /opt/hadoop/etc/hadoop/hadoop-env.sh && \
    sed 's:^# - SPARK_PID_DIR.*:export SPARK_PID_DIR=/var/run/spark:' /opt/spark/conf/spark-env.sh.template > /opt/spark/conf/spark-env.sh && \
    echo "export SPARK_DIST_CLASSPATH=$(JAVA_HOME=/usr /opt/hadoop/bin/hadoop classpath)" >> /opt/spark/conf/spark-env.sh && \
    mkdir /etc/hadoop/ /etc/spark/ && \
    ln -s /opt/hadoop/etc/hadoop /etc/hadoop/conf && \
    ln -s /opt/spark/conf /etc/spark/conf

# Add files
ADD container_root /

RUN chown -R hdfs:hadoop /opt/hadoop

CMD /run.sh
