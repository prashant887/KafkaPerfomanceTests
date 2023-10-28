-------------------------------------------------------------------

# Configurations to improve the throughput of the broker

# https://strimzi.io/blog/2021/06/08/broker-tuning/

# num.network.threads: Network threads  handle requests to the Kafka cluster, such as produce and fetch requests from client applications. Adjust the number of network threads to reflect the replication factor and the levels of activity from client producers and consumers interacting with the Kafka cluster. To reduce congestion and regulate the request traffic, you can use queued.max.requests to limit the number of requests allowed in the request queue before the network thread is blocked.

# num.io.threads: I/O threads (num.io.threads) pick up requests from the request queue to process them. Adding more threads can improve throughput, but the number of CPU cores and disk bandwidth imposes a practical upper limit. A good starting point might be to start with the default of 8 multiplied by the number of disks.

# replica.socket.receive.buffer.bytes: If threads are slow or limited due to the number of disks, try increasing the size of the buffers for network requests to improve throughput

# socket.request.max.bytes: Maximum number of bytes Kafka can receive

# socket.send.buffer.bytes and socket.receive.buffer.bytes: buffers for sending and receiving messages might be too small for the required throughput.

-------------------------------------------------------

# Open up server-0.properties and show the configuration

# Now let's run some tests with the current configuration

kafka-run-class.sh kafka.tools.EndToEndLatency \
localhost:9092 \
broker_tuning 25000 all 1024

# My latency was around 2.5 seconds

# Run producer test (note the throughput MB/sec)


echo "-----------------RESULTS-----------------";
kafka-producer-perf-test.sh \
--topic broker_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer.config $KAFKA_HOME/config/producer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(""))[]';
echo "------------------------------------------";


# Run the consumer test (note the throughput MB.sec)

echo "-----------------RESULTS-----------------";
kafka-consumer-perf-test.sh \
--topic broker_tuning \
--bootstrap-server localhost:9092 \
--messages 25000 \
--consumer.config $KAFKA_HOME/config/consumer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(" = "))[]';
echo "------------------------------------------";


# Now make changes to the broker configuration

# IMPORTANT: Make this change in each broker (just replace the existing settings)

----
# The number of threads that the server uses for processing requests, which may include disk I/O
num.io.threads=12

# The send buffer (SO_SNDBUF) used by the socket server
socket.send.buffer.bytes=20480000

# The receive buffer (SO_RCVBUF) used by the socket server
socket.receive.buffer.bytes=20480000

# The maximum size of a request that the socket server will accept (protection against OOM)
socket.request.max.bytes=2048576000

replica.socket.receive.buffer.bytes=90000
----


# IMPORTANT: Restart all 3 brokers

# Now run the same tests again

kafka-run-class.sh kafka.tools.EndToEndLatency \
localhost:9092 \
broker_tuning 25000 all 1024

# Average latency may have increased (not necessary)


echo "-----------------RESULTS-----------------";
kafka-producer-perf-test.sh \
--topic broker_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer.config $KAFKA_HOME/config/producer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(""))[]';
echo "------------------------------------------";


# Throughput should have gone up


echo "-----------------RESULTS-----------------";
kafka-consumer-perf-test.sh \
--topic broker_tuning \
--bootstrap-server localhost:9092 \
--messages 25000 \
--consumer.config $KAFKA_HOME/config/consumer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(" = "))[]';
echo "------------------------------------------";


# Again throughput should have gone up

