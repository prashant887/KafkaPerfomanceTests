# All the links used in this demo

# https://medium.com/metrosystemsro/apache-kafka-how-to-test-performance-for-clients-configured-with-ssl-encryption-3356d3a0d52b
# https://www.confluent.io/blog/configure-kafka-to-minimize-latency/
# https://developers.redhat.com/articles/2022/05/03/fine-tune-kafka-performance-kafka-optimization-theorem
# https://www.cs.umd.edu/~abadi/papers/abadi-pacelc.pdf
# https://www.linkedin.com/pulse/fine-tuning-kafka-kiran-sk


----------------------------------------------------------------
# Let's set up a more real-world Kafka cluster with 3 brokers

# IMPORTANT: Before you record - do behind the scenes (no need to show in recording)

# Please kill the Zookeeper and the Kafka server that you have running (on 9092) - we won't use
# that any more - we will work with this real-world cluster

# Create the 3 server properties files that you need (have the files ready)

# server-0.properties
# server-1.properties
# server-2.properties


---------- Start recording from here


# Drag $KAFKA_HOME/config/ as a folder in sublime text

# Goto $KAFKA_HOME/config/

# Show the 3 server.properties file
# Change the below mentioned properties using sublime text

# ---------server-0.properties---------
# broker.id=0
# listeners=PLAINTEXT://127.0.0.1:9092
# advertised.listeners=PLAINTEXT://127.0.0.1:9092
# log.dirs=/tmp/kafka-logs-0

# ---------server-1.properties---------
# broker.id=1
# listeners=PLAINTEXT://127.0.0.1:9093
# advertised.listeners=PLAINTEXT://127.0.0.1:9093
# log.dirs=/tmp/kafka-logs-1

# ---------server-2.properties---------
# broker.id=2
# listeners=PLAINTEXT://127.0.0.1:9094
# advertised.listeners=PLAINTEXT://127.0.0.1:9094
# log.dirs=/tmp/kafka-logs-2


# Run the below code in terminal

# Terminal 1 - tab 1:

zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties

# Terminal 1 - tab 2:

kafka-server-start.sh $KAFKA_HOME/config/server-0.properties

# Terminal 1 - tab 3:

kafka-server-start.sh $KAFKA_HOME/config/server-1.properties

# Terminal 1 - tab 4:

kafka-server-start.sh $KAFKA_HOME/config/server-2.properties


# This terminal can now be on another screen - we no longer need to see it

---------------------------------------------

# Now let's start with tuning the producer

# Open up terminal (Terminal - 2)
# Let's create another topic

kafka-topics.sh --create \
--topic performance_tuning \
--bootstrap-server localhost:9092 

# Listing the topics within the server

kafka-topics.sh --list \
--bootstrap-server localhost:9092

# Provides all the arguments for the command kafka-producer-perf-test
# to verify the producer performance

kafka-producer-perf-test.sh --help

# NOTE: open $KAFKA_HOME/config/producer.properties and show that 
# all the configurations are default and nothing is changed

# Here we run the producer performance test script
# The test will send 25000 records of size 1KB each
# throughput -1 means messages are produced as quickly as possible

# https://www.gbmb.org/kb-to-bytes


echo "-----------------RESULTS-----------------";
kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--producer.config $KAFKA_HOME/config/producer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(""))[]';
echo "------------------------------------------";

# We have found the below results

# -----------RESULT-----------
# 25000 records sent
# 14577.259475 records/sec (14.24 MB/sec)
# 324.74 ms avg latency
# 446.00 ms max latency
# 368 ms 50th
# 400 ms 95th
# 405 ms 99th
# 406 ms 99.9th.



# These are the observation found from the result

# We can observe about 14K records are being processed per second
# about 14MB is also being processed per second on an average
# with average latency of about 320ms and maximum latency of 
# about 440ms also 50% of messages took about 370ms to
# be produced and to be written on to the broker and about 405ms to 
# write 99% of messages


# we can get much more information by enabling --print-metrics 

kafka-producer-perf-test.sh \
--topic performance_tuning \
--num-records 25000 \
--record-size 1024 \
--throughput -1 \
--print-metrics \
--producer.config $KAFKA_HOME/config/producer.properties



