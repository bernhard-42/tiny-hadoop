source ./config.sh

podman rm -f tiny-hadoop 2> /dev/null

podman run -d \
       --hostname tiny-hadoop \
       --name tiny-hadoop \
       -v /opt/container-fs/hadoop:/hadoop \
       -p 4040:4040 \
       -p 8020:8020 \
       -p 8032:8032 \
       -p 8042:8042 \
       -p 8050:8050 \
       -p 8088:8088 \
       -p 50070:50070 \
       -p 50010:50010 \
       -p 50020:50020 \
       -p 50075:50075 \
       -p 50090:50090 \
       tiny-hadoop:$TAG \
       /run.sh
