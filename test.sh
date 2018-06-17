echo "Testing HDFS ..."
curl -s localhost:50070/webhdfs/v1/?op=LISTSTATUS | jq .

echo "Testing YARN ..."
curl -s localhost:8088/ws/v1/cluster/scheduler | jq .

echo "Testing Hbase ..."
curl -i -X PUT \
  'http://localhost:16060/test/schema' \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"@name":"test","ColumnSchema":[{"name":"data"}]}'

curl -i localhost:16060/

curl -v -X DELETE \
  'http://localhost:16060/test/schema' \
  -H "Accept: application/json"

curl -i localhost:16060/

echo "Testing Oozie ..."
curl -s localhost:11000/oozie/v1/jobs | jq .
