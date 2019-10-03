source ./config.sh

sudo docker build -t tiny-hadoop:$TAG \
            --build-arg HADOOP_VERSION=${HADOOP_VERSION} \
            --build-arg SPARK_VERSION=${SPARK_VERSION} \
            .
