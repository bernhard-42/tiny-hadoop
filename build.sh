source ./config.sh

docker build -t tiny-hadoop:$TAG \
       --build-arg HADOOP_VERSION=${HADOOP_VERSION} \
       --build-arg SPARK_VERSION=${SPARK_VERSION} \
       --build-arg HBASE_VERSION=${HBASE_VERSION} \
       --build-arg OOZIE_VERSION=${OOZIE_VERSION} \
       .
