#
# Stage 1: Building Oozie
#

FROM tiny-hadoop-base:latest

ARG HADOOP_VERSION
ARG OOZIE_VERSION

RUN apt-get install -y default-jdk maven && \
    cd /tmp && \
    wget http://www-eu.apache.org/dist/oozie/${OOZIE_VERSION}/oozie-${OOZIE_VERSION}.tar.gz && \
    tar -zxvf /tmp/oozie-${OOZIE_VERSION}.tar.gz
RUN cd /tmp/oozie-${OOZIE_VERSION} && \
    bin/mkdistro.sh -DskipTests -Puber -Dhadoop.version=${HADOOP_VERSION}
RUN cp /tmp/oozie-${OOZIE_VERSION}/distro/target/oozie-${OOZIE_VERSION}-distro.tar.gz /tmp

# RUN mkdir /tmp/oozie-dostro/ && \
#     cp /tmp/oozie-${OOZIE_VERSION}/distro/target/oozie-${OOZIE_VERSION}-distro.tar.gz /tmp/distro

# # == Or use a formerly created oozie dist:
# COPY oozie-${OOZIE_VERSION}-distro.tar.gz /tmp


#
# Stage 2: Installing Oozie
#

FROM tiny-hadoop-base:latest

ARG HADOOP_VERSION
ARG OOZIE_VERSION

COPY --from=0 /tmp/oozie-${OOZIE_VERSION}-distro.tar.gz /tmp

RUN cd /opt && \
    tar -zxvf /tmp/oozie-${OOZIE_VERSION}-distro.tar.gz && \
    ln -s /opt/oozie-${OOZIE_VERSION} /opt/oozie && \
    cd /opt/oozie && \
    tar -zxvf oozie-client-${OOZIE_VERSION}.tar.gz && \
    mv oozie-client-${OOZIE_VERSION}/lib/ . && \
    mv oozie-client-${OOZIE_VERSION}/conf/oozie-client-env.sh conf/ && \
    rm -fr oozie-client-${OOZIE_VERSION}.tar.gz docs.zip oozie-examples.tar.gz oozie-client-${OOZIE_VERSION}/ && \
    mkdir libext && \
    cp -n /opt/hadoop/share/hadoop/*/hadoop-*.jar \
          /opt/hadoop/share/hadoop/*/lib/*.jar \
          oozie-core/oozie-core-${OOZIE_VERSION}.jar \
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
