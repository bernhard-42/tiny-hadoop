source ./config.sh
docker run -d \
       --hostname local-hadoop \
       --name local-hadoop \
       -v /opt/hadoop-docker-fs:/hadoop \
       -v /opt/hadoop-docker-fs:/opt/oozie-4.3.1/data/ \
       -p 8020:8020 \
       -p 8032:8032 \
       -p 8042:8042 \
       -p 8050:8050 \
       -p 8088:8088 \
       -p 11000:11000 \
       -p 50070:50070 \
       -p 50010:50010 \
       -p 50020:50020 \
       -p 50075:50075 \
       -p 50090:50090 \
       hadoop:$TAG \
       /run.sh

docker logs -f local-hadoop
