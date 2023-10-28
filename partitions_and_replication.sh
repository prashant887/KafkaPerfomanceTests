# In the next demo lets check how the partition effects the performance
# of the kafka producer

# A topic partition is a unit of parallelism in Kafka. Messages to different partitions can be sent in parallel by producers, written in parallel to different brokers, and read in parallel by different consumers. Therefore, more partitions usually lead to more throughput. Purely from a throughput perspective, you should be able to get the full throughput from a Kafka cluster with an order of 10 partitions per broker. You may need more topic partitions to support your application logic.

# Too many partitions may have a negative effect on end-to-end latency. More partitions per topic generally lead to less batching on producers. More topic partitions per broker lead to more overhead per replica follower fetch request. Each fetch request has to enumerate partitions the follower is interested in, and the leader has to examine the state and fetch data from each partition in the request, generally leading to smaller disk IO. Therefore, too many partitions may lead to large commit times and a high CPU load on brokers, resulting in longer queueing delays.


# First lets create 3 topics with 1, 10, 20 partitions

# In terminal

kafka-topics.sh --create \
--topic partitions_1 \
--bootstrap-server localhost:9092 \
--partitions 1 \
--replication-factor 1

kafka-topics.sh --create \
--topic partitions_10 \
--bootstrap-server localhost:9092 \
--partitions 10 \
--replication-factor 1


kafka-topics.sh --create \
--topic partitions_100 \
--bootstrap-server localhost:9092 \
--partitions 100 \
--replication-factor 1

# Listing the topics within the server

kafka-topics.sh --list \
--bootstrap-server localhost:9092

# Run the below code in the Terminal

echo "----------------PARTITIONS 1----------------";
kafka-producer-perf-test.sh \
--topic partitions_1 \
--num-records 50000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------PARTITIONS 10----------------";
kafka-producer-perf-test.sh \
--topic partitions_10 \
--num-records 50000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------PARTITIONS 100----------------";
kafka-producer-perf-test.sh \
--topic partitions_100 \
--num-records 50000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties;



# We have found the below results

# RESULT
# ----------------PARTITIONS 1----------------
# 81609 records sent, 16321.8 records/sec (15.94 MB/sec), 44.4 ms avg latency, 412.0 ms max latency.
# 100000 records sent, 17003.910900 records/sec (16.61 MB/sec), 41.97 ms avg latency, 412.00 ms max latency, 8 ms 50th, 219 ms 95th, 257 ms 99th, 278 ms 99.9th.
# ----------------PARTITIONS 10----------------
# 82425 records sent, 16485.0 records/sec (16.10 MB/sec), 4.9 ms avg latency, 390.0 ms max latency.
# 100000 records sent, 16980.811683 records/sec (16.58 MB/sec), 4.80 ms avg latency, 390.00 ms max latency, 3 ms 50th, 13 ms 95th, 19 ms 99th, 30 ms 99.9th.
# ----------------PARTITIONS 100----------------
# 76300 records sent, 15260.0 records/sec (14.90 MB/sec), 7.9 ms avg latency, 421.0 ms max latency.
# 100000 records sent, 16005.121639 records/sec (15.63 MB/sec), 7.37 ms avg latency, 421.00 ms max latency, 6 ms 50th, 18 ms 95th, 26 ms 99th, 39 ms 99.9th.


# Observations

# Partition_1 throughput should be lower than partition_10
# Partition_100 should have a higher average latency than partition_10
# IMPORTANT NOTE: I had to run this a few times to get the throughput to increase from partitions_1 to partitions_10


# However, a very large number of partitions causes the creation of more metadata that needs to be passed and processed across all brokers and clients. This increased metadata can degrade end-to-end latency unless more resources are added to the brokers. This is a somewhat simplified description of how partitions work on Kafka, but it will serve to demonstrate the main tradeoff that the number of partitions leads to in our context.

# You should be able to get the full throughput from a Kafka cluster with an order of 10 partitions per broke

# Delete all the unnessary topics

kafka-topics.sh --delete --topic "partitions_1" \
--bootstrap-server localhost:9092

kafka-topics.sh --delete --topic "partitions_10" \
--bootstrap-server localhost:9092

kafka-topics.sh --delete --topic "partitions_100" \
--bootstrap-server localhost:9092

# In the next demo lets check how the replication factor effects the performance
# of the kafka producer




---------------------------------------------------------------------------------

# Creating a topic with replication factor of 1 

kafka-topics.sh --create \
--topic rf_1 \
--bootstrap-server localhost:9092 \
--replication-factor 1

# Creating a topic with replication factor of 3

kafka-topics.sh --create \
--topic rf_3 \
--bootstrap-server localhost:9092 \
--replication-factor 3

# Creating a topic with replication factor of 6

kafka-topics.sh --create \
--topic rf_6 \
--bootstrap-server localhost:9092 \
--replication-factor 6



echo "----------------REPLICATION FACTOR 1----------------";
kafka-producer-perf-test.sh \
--topic rf_1 \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------REPLICATION FACTOR 3----------------";
kafka-producer-perf-test.sh \
--topic rf_3 \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties;
echo "----------------REPLICATION FACTOR 6----------------";
kafka-producer-perf-test.sh \
--topic rf_6 \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties;


# We have found the below results

# ----------------REPLICATION FACTOR 1----------------
# 25000 records sent, 13020.833333 records/sec (12.72 MB/sec), 370.54 ms avg latency, 498.00 ms max latency, 417 ms 50th, 493 ms 95th, 496 ms 99th, 497 ms 99.9th.
# ----------------REPLICATION FACTOR 2----------------
# 25000 records sent, 8093.234056 records/sec (7.90 MB/sec), 926.80 ms avg latency, 1469.00 ms max latency, 1010 ms 50th, 1417 ms 95th, 1459 ms 99th, 1468 ms 99.9th.
# ----------------REPLICATION FACTOR 4----------------
# 25000 records sent, 5424.170102 records/sec (5.30 MB/sec), 1387.68 ms avg latency, 2540.00 ms max latency, 1436 ms 50th, 2371 ms 95th, 2510 ms 99th, 2539 ms 99.9th.



# These are the observation found from the result

# We can clearly see as the number of replication factor increases the latency increases


# Delete all the unnessary topics
kafka-topics.sh --delete --topic "rf_1" \
--bootstrap-server localhost:9092

kafka-topics.sh --delete --topic "rf_3" \
--bootstrap-server localhost:9092

kafka-topics.sh --delete --topic "rf_6" \
--bootstrap-server localhost:9092







