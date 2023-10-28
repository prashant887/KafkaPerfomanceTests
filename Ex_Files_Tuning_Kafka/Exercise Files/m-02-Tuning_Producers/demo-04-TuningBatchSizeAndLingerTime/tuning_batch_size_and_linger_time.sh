# All the links used in this demo

# Let's observe how batch size and linger time effects the performance of the 
# producer

# https://docs.confluent.io/platform/current/installation/configuration/producer-configs.html#producerconfigs_batch.size
# https://docs.confluent.io/platform/current/installation/configuration/producer-configs.html#producerconfigs_linger.ms

#  A Kafka producer batches records for the same topic partition to optimize network and IO requests issued to Kafka. By default, the producer is configured to send the batch immediately, in which case the batch usually contains one or a few records produced by the application at about the same time. To improve batching, the producer can be configured with a small amount of artificial delay (linger.ms) that the record will spend waiting for more records to arrive and get added to the same batch. Once the linger.ms delay has passed or the batch size reaches the maximum configured size (batch.size), the batch is considered complete.

# If compression is enabled (compression.type), the Kafka producer compresses the completed batch. Before batch completion, the size of the batch is estimated based on a combination of the compression type and the previously observed compression ratio for the topic.

# On the producer side, batching is controlled by two configuration parameters: batch.size (default is 16 KB), which limits the size of the batch, and linger.ms (default is 0 ms), which limits the amount of the delay. If your application sends records to the internal Kafka producer with a high rate, the batches may fill up to the maximum even with linger.ms = 0. If the application rate is low, increasing batching requires increasing linger.ms - just increasing the batch size may not help.


# In terminal

echo "----------------BATCH.SIZE=16384, LINGER.MS=0(DEFAULT)----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------BATCH.SIZE=2048, LINGER.MS=0(REDUCED BATCH SIZE)----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all batch.size=2048 linger.ms=0 \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------LINGER.MS=10(INCREASED LINGER.MS)----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all linger.ms=10 \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------BATCH.SIZE=25000, LINGER.MS=100(INCREASED BATCH SIZE, LINGER.MS)----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all batch.size=25000 linger.ms=100 \
--producer.config $KAFKA_HOME/config/producer.properties;

# We have found the below results

# ----------------BATCH.SIZE=16384, LINGER.MS=0(DEFAULT)----------------
# 25000 records sent, 6197.322757 records/sec (6.05 MB/sec), 1259.94 ms avg latency, 1901.00 ms max latency, 1473 ms 50th, 1824 ms 95th, 1891 ms 99th, 1900 ms 99.9th.
# ----------------BATCH.SIZE=2048, LINGER.MS=0(REDUCED BATCH SIZE)----------------
# 3450 records sent, 690.0 records/sec (0.67 MB/sec), 2395.1 ms avg latency, 4204.0 ms max latency.
# 4935 records sent, 987.0 records/sec (0.96 MB/sec), 6592.1 ms avg latency, 8786.0 ms max latency.
# 5649 records sent, 1129.8 records/sec (1.10 MB/sec), 11170.6 ms avg latency, 13443.0 ms max latency.
# 6321 records sent, 1264.2 records/sec (1.23 MB/sec), 14755.1 ms avg latency, 15600.0 ms max latency.
# 25000 records sent, 1057.574347 records/sec (1.03 MB/sec), 10460.44 ms avg latency, 15600.00 ms max latency, 12246 ms 50th, 15178 ms 95th, 15518 ms 99th, 15589 ms 99.9th.
# ----------------LINGER.MS=10(INCREASED LINGER.MS)----------------
# 25000 records sent, 7100.255609 records/sec (6.93 MB/sec), 972.56 ms avg latency, 1531.00 ms max latency, 1029 ms 50th, 1454 ms 95th, 1504 ms 99th, 1530 ms 99.9th.
# ----------------BATCH.SIZE=25000, LINGER.MS=100(INCREASED BATCH SIZE, LINGER.MS)----------------
# 25000 records sent, 10150.223305 records/sec (9.91 MB/sec), 600.73 ms avg latency, 1037.00 ms max latency, 620 ms 50th, 995 ms 95th, 1033 ms 99th, 1036 ms 99.9th.

# Case 1
# Here our producer produces at a very high rate and with linger.ms = 0, all of the 25,000 records are sent in one batch i.e. the batch fills up even with linger.ms = 0

# Case 2
# By reducing the batch size, we can see that several batches are needed to send the results and the average latency overall is higher

# Case 3
# We increase the linger.ms even though our application produces at a very high rate. This helps reduce the tail latencies (you may find that the maximum latency for messages is lower)

# If you care about tail latencies, increasing linger.ms may reduce the request rate and the size of request bursts that can arrive to brokers at the same time. The bigger the burst, the higher the latency of the requests in the tail of the burst. These bursts determine your tail latencies. Therefore, increasing linger.ms may significantly reduce your tail latencies, even though your average latency may increase by the additional amount of the artificial delay in the producer.

# Case 4
# Increasing the batch size and linger.ms greatly reduces the avg latency for messages


-----------------------------------------------------------------------------------------


# -----------OPEN config/producer.properties----------- 
# Uncomment the commpression type
### producer_v2.properties
compression.type=gzip

# In the above we have increased our maximum batch size 
# from 16384 bytes to 25000 bytes
# and we have changed the linger from 0 to 100ms which is the 
# maximum duration to fill the batch 


# Now run the below code in terminal

echo "-----------------RESULTS (default values of batch size)-----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(""))[]';
echo "------------------------------------------";
echo "-----------------RESULTS (higher values of batch size and linger.ms)-----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer-props acks=all batch.size=25000 linger.ms=100 \
--producer.config $KAFKA_HOME/config/producer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(""))[]';
echo "------------------------------------------";


# We have found the below results

# -----------------RESULTS (default values of batch size)-----------------
# 25000 records sent
# 8617.718028 records/sec (8.42 MB/sec)
# 220.68 ms avg latency
# 401.00 ms max latency
# 257 ms 50th
# 373 ms 95th
# 380 ms 99th
# 381 ms 99.9th.
# ------------------------------------------
# -----------------RESULTS (higher values of batch size and linger.ms)-----------------
# 25000 records sent
# 9164.222874 records/sec (8.95 MB/sec)
# 71.29 ms avg latency
# 373.00 ms max latency
# 44 ms 50th
# 212 ms 95th
# 233 ms 99th
# 237 ms 99.9th.
# ------------------------------------------


# These are the observation found from the result

# We can observe the we are able to send about 6MB per second
# with an average latency of 31ms

# Average latency is greatly improved with compression too



