#
# Stage 1: Building Oozie
#
FROM ubuntu:16.04

ARG HADOOP_VERSION
ARG OOZIE_VERSION

RUN apt-get update && \
    apt-get install -y default-jdk maven wget less zip unzip && \
    cd /tmp && \
    wget http://www-eu.apache.org/dist/oozie/${OOZIE_VERSION}/oozie-${OOZIE_VERSION}.tar.gz && \
    tar -zxvf /tmp/oozie-${OOZIE_VERSION}.tar.gz
RUN echo "=== BUILDING OOZIE ===" && \
    cd /tmp/oozie-${OOZIE_VERSION} && \
    bin/mkdistro.sh -DskipTests -Puber -Dhadoop.version=${HADOOP_VERSION}
RUN cp /tmp/oozie-${OOZIE_VERSION}/distro/target/oozie-${OOZIE_VERSION}-distro.tar.gz /tmp


#
# Stage 2: Installing Oozie
#
FROM ubuntu:16.04

ARG HADOOP_VERSION
ARG SPARK_VERSION
ARG HBASE_VERSION
ARG OOZIE_VERSION

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

# Installation of Oozie

COPY --from=0 /tmp/oozie-${OOZIE_VERSION}-distro.tar.gz /tmp

RUN echo "=== OOZIE ===" && \
    cd /opt && \
    tar -zxvf /tmp/oozie-${OOZIE_VERSION}-distro.tar.gz && \
    ln -s /opt/oozie-${OOZIE_VERSION} /opt/oozie && \
    cd /opt/oozie && \
    tar -zxvf oozie-client-${OOZIE_VERSION}.tar.gz && \
    mv oozie-client-${OOZIE_VERSION}/lib/ . && \
    mv oozie-client-${OOZIE_VERSION}/conf/oozie-client-env.sh conf/ && \
    rm -fr oozie-client-${OOZIE_VERSION}.tar.gz docs.zip oozie-examples.tar.gz oozie-client-${OOZIE_VERSION}/ && \
    mkdir libext && \
    cp -n /opt/hadoop/share/hadoop/*/hadoop-*.jar /opt/hadoop/share/hadoop/*/lib/*.jar oozie-core/oozie-core-${OOZIE_VERSION}.jar libext && \
    wget http://central.maven.org/maven2/log4j/apache-log4j-extras/1.2.17/apache-log4j-extras-1.2.17.jar && \
    wget http://central.maven.org/maven2/org/apache/openjpa/openjpa-all/2.4.2/openjpa-all-2.4.2.jar && \
    wget http://central.maven.org/maven2/org/jdom/jdom/1.1.3/jdom-1.1.3.jar && \
    wget http://central.maven.org/maven2/org/apache/derby/derby/10.10.1.1/derby-10.10.1.1.jar && \
    wget https://ext4all.com/ext/download/ext-2.2.zip && \
    mv apache-log4j-extras-1.2.17.jar openjpa-all-2.4.2.jar jdom-1.1.3.jar derby-10.10.1.1.jar ext-2.2.zip libext && \
    useradd -m oozie && \
    mkdir /opt/oozie/logs && \
    chown -R oozie:oozie /opt/oozie/logs/ && \
    bin/oozie-setup.sh prepare-war && \
    echo oozie-${OOZIE_VERSION} >> /opt/hadoop-version.txt

# Configuration
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
