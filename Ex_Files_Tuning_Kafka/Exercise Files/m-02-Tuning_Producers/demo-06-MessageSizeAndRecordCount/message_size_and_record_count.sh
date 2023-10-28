
# Lets check what effect does message size have on the producer performance

# In terminal

for i in 1000 10000 100000;
  do
  echo ""
  echo "No. of Records: 25000" "Record Size:" $i
  kafka-producer-perf-test.sh --topic performance_tuning \
  --num-records 25000 --record-size $i --throughput -1 \
  --producer-props acks=all \
  --producer.config $KAFKA_HOME/config/producer.properties
  echo "------------------------------------------"
done;

# We have found the below results

# No. of Records: 25000 Record Size:  1000 -> (6.58 MB/sec), 15.58 ms avg latency
# No. of Records: 25000 Record Size:  100000 -> (11.98 MB/sec), 94.49 ms avg latency
# No. of Records: 25000 Record Size:  100000 -> (15.47 MB/sec), 72.41 ms avg latency

# Larger record sizes increases latencies
# For larger records there will be many more batches sent
# May result in fewer records per batch

------------------------------------------------------------------------------------------

# Lets check what effect does number of records have on the producer performance (at what rate the producer produces)

for i in 1000 10000 100000;
  do
  echo ""
  echo "No. of Records:" $i "Record Size: 1024"
  kafka-producer-perf-test.sh --topic performance_tuning \
  --num-records $i --record-size 1024 --throughput -1 \
  --producer-props acks=all \
  --producer.config $KAFKA_HOME/config/producer.properties
  echo "------------------------------------------"
done;

# We have found the below results

# No. of Records: 1000 Record Size: 1024 -> (0.50 MB/sec), 105.09 ms avg latency
# No. of Records: 10000 Record Size: 1024 -> (4.50 MB/sec), 70.91 ms avg latency
# No. of Records: 100000 Record Size: 1024 -> (6.48 MB/sec), 29.58 ms avg latency


# More records improves throughput
# More records implies many more batches will be created


