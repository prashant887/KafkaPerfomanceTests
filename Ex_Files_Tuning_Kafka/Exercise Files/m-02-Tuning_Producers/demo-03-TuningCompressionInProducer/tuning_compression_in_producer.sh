# All the links used in this demo

# By default, Kafka producers are configured with no compression and are controlled by the compression.type configuration parameter. Compression adds processing overhead on the producer side to compress the message, processing overhead on brokers to decompress the message for validation before appending it to the log, and overhead on the consumer side to decompress the message. The broker’s compression should be set to “producer” in order to save the recompression cost, in which case the broker appends the original compressed message sent by the producer.

# Although compression increases processing overhead, it may reduce overall end-to-end latency because it can significantly reduce the amount of bandwidth required to process your data, which reduces per-broker load. Since compression is done on batches, better batching usually means better compression.


# Now lets check which compression is the best we have gzip, snappy, lz4, zstd
# https://developer.ibm.com/articles/benefits-compression-kafka-messaging/#:~:text=Supported%20Compression%20Types%20in%20Kafka&text=Gzip,Zstd

# Observe that latency falls with compression

echo "----------------WITHOUT COMPRESSION----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all compression.type=none \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------WITH COMPRESSION----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all compression.type=zstd \
--producer.config $KAFKA_HOME/config/producer.properties;

# We have found the below results

# ----------------WITHOUT COMPRESSION----------------
# 25000 records sent, 13283.740701 records/sec (12.97 MB/sec), 451.65 ms avg latency, 575.00 ms max latency, 538 ms 50th, 570 ms 95th, 574 ms 99th, 575 ms 99.9th.
# ----------------WITH COMPRESSION----------------
# 25000 records sent, 12425.447316 records/sec (12.13 MB/sec), 44.54 ms avg latency, 608.00 ms max latency, 44 ms 50th, 93 ms 95th, 96 ms 99th, 97 ms 99.9th.


# These are the observation found from the result

# observe without compression we can observe about 13K records are being sent
# with an average latency of 450ms but with compression in my case a random
# compression of zstd we are able to sent 12K records with an average latency of
# 44ms that is a significant reduction in the latency


-----------------------------------------------------------------
# GZip gives the best latency because it has the highest compression ratio


echo "----------------GZIP----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all compression.type=gzip \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------SNAPPY----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all compression.type=snappy \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------LZ4----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all compression.type=lz4 \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------ZSTD----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all compression.type=zstd \
--producer.config $KAFKA_HOME/config/producer.properties

# We have found the below results

# ----------------RESULTS----------------
# ----------------GZIP----------------
# 25000 records sent, 10789.814415 records/sec (10.54 MB/sec), 6.41 ms avg latency, 460.00 ms max latency, 4 ms 50th, 17 ms 95th, 24 ms 99th, 26 ms 99.9th.
# ----------------SNAPPY----------------
# 25000 records sent, 10879.025239 records/sec (10.62 MB/sec), 378.44 ms avg latency, 737.00 ms max latency, 447 ms 50th, 498 ms 95th, 502 ms 99th, 504 ms 99.9th.
# ----------------LZ4----------------
# 25000 records sent, 12481.278083 records/sec (12.19 MB/sec), 364.90 ms avg latency, 561.00 ms max latency, 426 ms 50th, 487 ms 95th, 489 ms 99th, 490 ms 99.9th.
# ----------------ZSTD----------------
# 25000 records sent, 13034.410845 records/sec (12.73 MB/sec), 177.47 ms avg latency, 614.00 ms max latency, 182 ms 50th, 291 ms 95th, 296 ms 99th, 297 ms 99.9th.


# These are the observation found from the result


# looks like gzip is giving the best performance