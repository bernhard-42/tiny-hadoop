FROM ubuntu:16.04

# Installation Hadoop and Spark
RUN apt-get update && \
    apt-get install -y default-jre wget vim-tiny less openssh-client openssh-server net-tools python zip unzip && \
    cd /tmp && \
    wget http://www-eu.apache.org/dist/hadoop/common/hadoop-2.8.4/hadoop-2.8.4.tar.gz && \
    wget http://www-eu.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-without-hadoop.tgz && \
    cd /opt && \
    tar -zxvf /tmp/hadoop-2.8.4.tar.gz && \
    rm -fr /opt/hadoop-2.8.4/share/doc/ && \
    ln -s hadoop-2.8.4 hadoop && \
    tar -zxvf /tmp/spark-2.3.0-bin-without-hadoop.tgz && \
    ln -s spark-2.3.0-bin-without-hadoop spark && \
    rm /tmp/*.tar.gz

# Installation Oozie

# == Either crteate oozie dist (downloads the internet):
# RUN appt-get install default-jdk maven && \
#     cd /tmp && \
#     wget http://www-eu.apache.org/dist/oozie/4.3.1/oozie-4.3.1.tar.gz && \
#     tar -zxvf /tmp/oozie-4.3.1.tar.gz && \
#     cd /tmp/oozie-4.3.1.tar.gz && \
#     bin/mkdistro.sh -DskipTests -Puber -Dhadoop.version=2.8.4 && \
#     cp /opt/oozie/distro/target/oozie-4.3.1-distro.tar.gz /tmp

# == Or use a formerly created oozie dist:
COPY oozie-4.3.1-distro.tar.gz /tmp

RUN cd /opt && \
    tar -zxvf /tmp/oozie-4.3.1-distro.tar.gz && \
    ln -s /opt/oozie-4.3.1 /opt/oozie && \
    cd /opt/oozie && \
    tar -zxvf oozie-client-4.3.1.tar.gz && \
    mv oozie-client-4.3.1/lib/ . && \
    mv oozie-client-4.3.1/conf/oozie-client-env.sh conf/ && \
    rm -fr oozie-client-4.3.1.tar.gz docs.zip oozie-examples.tar.gz oozie-client-4.3.1/ && \
    mkdir libext && \
    cp -n /opt/hadoop/share/hadoop/*/hadoop-*.jar \
          /opt/hadoop/share/hadoop/*/lib/*.jar \
          oozie-core/oozie-core-4.3.1.jar \
          libext && \
    wget http://central.maven.org/maven2/log4j/apache-log4j-extras/1.2.17/apache-log4j-extras-1.2.17.jar && \
    wget http://central.maven.org/maven2/org/apache/openjpa/openjpa-all/2.4.2/openjpa-all-2.4.2.jar && \
    wget http://central.maven.org/maven2/org/jdom/jdom/1.1.3/jdom-1.1.3.jar && \
    wget http://central.maven.org/maven2/org/apache/derby/derby/10.10.1.1/derby-10.10.1.1.jar && \
    wget https://ext4all.com/ext/download/ext-2.2.zip && \
    mv apache-log4j-extras-1.2.17.jar \
       openjpa-all-2.4.2.jar \
       jdom-1.1.3.jar \
       derby-10.10.1.1.jar \
       ext-2.2.zip \
       libext && \
    useradd -m oozie && \
    mkdir /opt/oozie/logs && \
    chown -R oozie:oozie /opt/oozie/logs/ && \
    bin/oozie-setup.sh prepare-war

# Configuration
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    echo "JAVA_HOME=/usr" >> /etc/environment && \
    echo "HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop/conf" >> /etc/environment && \
    echo "export SPARK_DIST_CLASSPATH=$(JAVA_HOME=/usr /opt/hadoop/bin/hadoop classpath)" > /opt/spark/conf/spark-env.sh

ADD container_root /

CMD /run.sh
