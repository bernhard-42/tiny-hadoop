echo "Testing HDFS ..."
curl -s localhost:50070/webhdfs/v1/?op=LISTSTATUS | jq .

echo "Testing YARN ..."
curl -s localhost:8088/ws/v1/cluster/scheduler | jq .