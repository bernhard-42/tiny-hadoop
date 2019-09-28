echo "Testing HDFS ..."
curl -s localhost:50070/webhdfs/v1/?op=LISTSTATUS | jq .
