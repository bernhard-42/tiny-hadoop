source ./config.sh

docker rm -f tiny-hadoop-base

docker run -d \
       --hostname tiny-hadoop-base \
       --name tiny-hadoop-base \
       -v /opt/docker-fs/hadoop:/hadoop \
       -v /opt/docker-fs/hbase:/hbase \
       -p 8020:8020 \
       -p 8032:8032 \
       -p 8042:8042 \
       -p 8050:8050 \
       -p 8088:8088 \
       -p 16000:16000 \
       -p 16010:16010 \
       -p 16060:16060 \
       -p 16070:16070 \
       -p 16301:16301 \
       -p 50070:50070 \
       -p 50010:50010 \
       -p 50020:50020 \
       -p 50075:50075 \
       -p 50090:50090 \
       tiny-hadoop-base:latest \
       /run.sh

docker logs -f tiny-hadoop-base
