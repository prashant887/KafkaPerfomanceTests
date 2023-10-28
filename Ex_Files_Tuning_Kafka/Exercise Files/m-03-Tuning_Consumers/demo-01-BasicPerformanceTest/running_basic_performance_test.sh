# All the links used in this demo

# https://medium.com/metrosystemsro/apache-kafka-how-to-test-performance-for-clients-configured-with-ssl-encryption-3356d3a0d52b
# https://blog.clairvoyantsoft.com/benchmarking-kafka-e7b7c289257d
# https://www.confluent.io/blog/configure-kafka-to-minimize-latency/

--------------------------------------------------------
# Show that we have the same set up as before

# Terminal with Zookeeper and Brokers running

# Tab 1 - Show Zookeper running
# Tab 2 - Show one broker running (just run server-0.properties)

# Delete the existing topic

kafka-topics.sh --delete --topic performance_tuning \
--bootstrap-server localhost:9092


# Re-create the topic with 3 partitions

kafka-topics.sh --create \
--topic performance_tuning \
--bootstrap-server localhost:9092


# Describes the topic in this case the topic name is performance_tuning

kafka-topics.sh --describe \
--topic performance_tuning \
--bootstrap-server localhost:9092


# Provides all the arguments for the command kafka-consumer-perf-test
# to verify the consumer performance

kafka-consumer-perf-test.sh --help


# NOTE: open $KAFKA_HOME/config/consumer.properties and show that everything is set to the default


# https://cwiki.apache.org/confluence/display/KAFKA/KIP-177%3A+Consumer+perf+tool+should+count+rebalance+time

# Here we run the consumer performance test script
# The test will receive/consume 25000 records
# by default there are 10 threads
# working

echo "-----------------RESULTS-----------------";
kafka-consumer-perf-test.sh \
--topic performance_tuning \
--bootstrap-server localhost:9092 \
--messages 25000 \
--consumer.config $KAFKA_HOME/config/consumer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(" = "))[]';
echo "------------------------------------------";


# We have found the below results

# -----------RESULT-----------
# start.time = 2022-10-17 17:04:39:589
# end.time = 2022-10-17 17:04:40:619
# data.consumed.in.MB = 24.6836
# MB.sec = 23.9647
# data.consumed.in.nMsg = 25276
# nMsg.sec = 24539.8058
# rebalance.time.ms = 518
# fetch.time.ms = 512
# fetch.MB.sec = 48.2101
# fetch.nMsg.sec = 49367.1875



# These are the observation found from the result

# we have consumer about 24MB of data
# and about 49K messages about 48MB where consumed every second
# fetch time is about 512ms