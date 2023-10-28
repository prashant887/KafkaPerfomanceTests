# All the links used in this demo

# https://www.javatpoint.com/apache-kafka-producer

# We have a property called aks means Acknowledgment
# Below we are running the same code but one where aks=0 
# which means producer sends the data to the broker but does 
# not wait for the acknowledgement
# and another where aks=1 which means that the leader of the broker only 
# acknowledgement and the producer will wait for only that
# and another where aks=all 
# which means producer sends the data and the acknowledgment is done by 
# both the leader and its followers

# Even if we configure brokers with multiple replicas, producers must also be configured for reliability via the acks configuration. Setting acks to all provides the strongest guarantee but also increases the time it takes the broker to acknowledge the produce request, as we discussed earlier.

# Slower acknowledgements from brokers usually decrease the throughput that can be achieved by a single producer, which in turn increases the wait time in the producer.

------------------------------------------------------------
# Delete the old topic which has the default replication factor 
# and create a new one with replication of 3

kafka-topics.sh --delete --topic "performance_tuning" \
--bootstrap-server localhost:9092


kafka-topics.sh --create \
--topic performance_tuning \
--replication-factor 3 \
--bootstrap-server localhost:9092 


# Now run the performance tests with different values for acks

echo "----------------acks=0----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=0 \
--producer.config $KAFKA_HOME/config/producer.properties
echo "----------------acks=1----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=1 \
--producer.config $KAFKA_HOME/config/producer.properties
echo "----------------acks=all----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer-props acks=all \
--producer.config $KAFKA_HOME/config/producer.properties

# We have found the below results

# -----------RESULT-----------
# ----------------acks=0----------------
# 25000 records sent, 16244.314490 records/sec (15.86 MB/sec), 145.79 ms avg latency, 445.00 ms max latency, 161 ms 50th, 208 ms 95th, 215 ms 99th, 216 ms 99.9th.
# ----------------acks=1----------------
# 25000 records sent, 14792.899408 records/sec (14.45 MB/sec), 276.67 ms avg latency, 452.00 ms max latency, 305 ms 50th, 370 ms 95th, 371 ms 99th, 372 ms 99.9th.
# ----------------acks=all----------------
# 25000 records sent, 13557.483731 records/sec (13.24 MB/sec), 381.93 ms avg latency, 506.00 ms max latency, 449 ms 50th, 496 ms 95th, 503 ms 99th, 505 ms 99.9th.


# These are the observation found from the result


# in my case where aks=0 we are getting lower latency of 145ms
# and where aks=1 we are getting an average latency of 276ms
# and where aks=all we are getting average latency of 381ms
# ie there is a significancy latency reduction when aks=0 compared to aks=1 and aks=all
# ie aks=0 < aks=1 < aks=all (LATENCY)
# having aks=0 will definitly increase the speed but there is a
# possiblity of data loss compared to aks=1 and compared to aks=all
# incase of aks=all we can rest asure that there wont be any sata loss
# ie aks=0 > aks=1 > aks=all (DATA LOSS)


-----------------------------------------------------------------
