# tiny-hadoop
A pseudo-distributed HDFS with YARN, Spark 2.3 and Oozie in a docker container usefull for testing clients that use WebHDFS, YARN and Oozie REST API.

You may not want to start real jobs in it ;-)

## Build

```bash
./build-base.sh
./build.sh
```

**Note:** The first run of `build.sh` builds an Oozie binary in stage 1. It downloads the maven part of the Internet and takes very long ...
If one only changes stage 2 in the Dockerfile, subsequent runs are pretty fast - as long as one doesn't remove the stage 1 interim image (maybe tag it after the first run).


## Run

```bash
./run.sh
```

This will init the container and start HDFS, YARN and Oozie in it.

## Simple REST API Tests

```bash
./test.sh
```

