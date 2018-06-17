source ./config.sh

docker build -t tiny-hadoop:$TAG \
       --file Dockerfile-oozie \
       --build-arg HADOOP_VERSION=${HADOOP_VERSION} \
       --build-arg OOZIE_VERSION=${OOZIE_VERSION} \
       .
