# A tiny hadoop stack

## 1 Build and Run

A pseudo-distributed HDFS with YARN, Spark 2.3 and pseudo-distributed HBase 1.1 in a docker container usefull for testing clients that use WebHDFS, YARN and Oozie REST API.

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
