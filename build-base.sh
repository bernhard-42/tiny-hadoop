source ./config.sh

docker build -t tiny-hadoop-base:latest \
       --file Dockerfile-base \
       --build-arg HADOOP_VERSION=${HADOOP_VERSION} \
       --build-arg SPARK_VERSION=${SPARK_VERSION} \
       .
