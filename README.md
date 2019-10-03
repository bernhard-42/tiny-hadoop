# A tiny hadoop stack

## 1 Build and Run

A pseudo-distributed HDFS with YARN, Spark 2.3 and pseudo-distributed HBase 1.1 in a docker container usefull for testing clients that use WebHDFS, YARN and Oozie REST API.

Note: Docker containers should have least 4G available (check restrictions)

- Build

    ```bash
    ./build.sh
    ```

- Run

    ```bash
    ./run.sh
    ```

    This will init the container and start HDFS, YARN, HBase and Oozie in it.


**Notes:**

- The first run of `build.sh` builds an Oozie binary in stage 1. It downloads the maven part of the Internet and takes very long ...
If one only changes stage 2 in the Dockerfile, subsequent runs are pretty fast - as long as one doesn't remove the stage 1 interim image (maybe tag it after the first run).
- You may not want to start real jobs in it ;-)


## 2 Simple REST API Tests

Wait until HBase is fully started (check via `localhost:16010`)

```bash
./test.sh
```

## 3 Exposed Ports

8020 Namenode
8032 Namenode IPC
8042 Datanode
8050 Resource Manager IPC
8088 Resource Manager Web UI
11000 Oozie
16000 HBase Master
16010 HBase Master Web UI
16060 HBase REST
16070 HBase Info
16301 HBase Region Server
50070 Namenode Web UI, WebHDFS (/webhdfs/v1)
50010 Datanode data transfer
50020 Datanode IPC
50075 Datanode Web UI
50090 Secondary Namenode

## 4 Infos

To get the memory footprint, wait until all services are started and then

Initialize:

```bash
docker exec -it tiny-hadoop bash -l -c "su -c '/opt/jvmtop/jvmtop.sh --once' oozie"
```

After this call root can also access Oozie:

```bash
docker exec -it tiny-hadoop bash -l -c /opt/jvmtop/jvmtop.sh
```

Show all hadoop service versions

```bash
docker exec -it tiny-hadoop cat /opt/hadoop-version.txt
```



# Kerberized HDFS

## Create Pod
sudo podman pod create -n kerberos-hadoop -p 88:88 -p 389:389 -p 636:636 -p 464:464 -p 749:749 -p 8389:8389 -p 4040:4040 -p 8020:8020 -p 8032:8032 -p 8042:8042 -p 8050:8050 -p 8088:8088 -p 50070:50070 -p 50010:50010 -p 50020:50020 -p 50075:50075 -p 50090:50090

## Create KDC server

cd runtime
tar -zxvf server.tgz
sudo podman load -i ldap-kdc-acme.localdomain-1.0.1.docker

HOSTNAME=kerberos-hadoop
REALM=ACME.LOCALDOMAIN
DOMAIN=acme.localdomain

sudo podman run --pod ${HOSTNAME} -d --name ldap-kdc ldap-kdc-${DOMAIN}:1.0.1
CID=$(sudo podman ps | awk '/ldap-kdc/ {print $1}')

sudo podman exec -it $CID bash -c 'echo "ank +needchange -pw secret hdfs/${HOSTNAME}@{REALM}" | kadmin.local'
sudo podman exec -it $CID bash -c 'echo "ank +needchange -pw secret HTTP/${HOSTNAME}@{REALM}" | kadmin.local'

sudo podman exec -it $CID bash -c 'mkdir /etc/security/keytabs/'
sudo podman exec -it $CID bash -c 'echo "xst -norandkey -k /etc/security/keytabs/hadoop.keytab hdfs/${HOSTNAME}@{REALM}" | kadmin.local'
sudo podman exec -it $CID bash -c 'echo "xst -norandkey -k /etc/security/keytabs/hadoop.keytab HTTP/${HOSTNAME}@{REALM}" | kadmin.local'
sudo podman cp $CID:/etc/security/keytabs/hadoop.keytab .

## Create Hadoop server

sudo podman run --pod ${HOSTNAME} -d --name hadoop --hostname hadoop -v /opt/container-fs/hadoop:/hadoop tiny-hadoop:1.0.0 run.sh

keytool -genkey -keyalg RSA -alias tomcat -keystore /etc/hadoop/conf/keystore -validity 10000 -keysize 2048

