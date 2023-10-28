# http://activisiongamescience.github.io/2016/06/15/Kafka-Client-Benchmarking/

# Behind the scenes run the same 1 Zookeeper and 3 Brokers

# Create a new topic with name 'producer_perf_tests'


kafka-topics.sh --create \
--topic producer_perf_tests \
--bootstrap-server localhost:9092 \
--partitions 10 \
--replication-factor 3


# Describe the topic in this case the topic name is performance_tuning

kafka-topics.sh --describe \
--topic producer_perf_tests \
--bootstrap-server localhost:9092


# Check that you have Python installed

python --version

# Install the Kafka Python API

pip install kafka-python

# Open up producer_perf_testing.py on Sublimetext and show the code

# Ensure the producer has these parameters (no gzip)

    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers, acks='all',
        batch_size=25000, linger_ms=100)

# Run the code on the terminal

python producer_perf_testing.py 


#### RESULT
# Processed 1000000 messages in 74.86 seconds
# 1.27 MB/sec
# 13358.01 messages/sec



#### Replace this one line of code in producer_benchmarking.py


    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers, acks='all',
        compression_type='gzip')


# We have found the below results

#### RESULT
# Processed 1000000 messages in 54.46 seconds
# 1.75 MB/sec
# 18363.56 messages/sec

# We can observe a significant improvement in messages/sec


# NOTE: Producer benchmarking would have produced 2MM messages (we have run it twice)
# Let's use a new topic for consumer perf testing


# Let's create a new topic for consumer testing


kafka-topics.sh --create \
--topic consumer_perf_tests \
--bootstrap-server localhost:9092 \
--partitions 10 \
--replication-factor 3


# Describe the topic in this case the topic name is performance_tuning

kafka-topics.sh --describe \
--topic consumer_perf_tests \
--bootstrap-server localhost:9092



# Show the consumer code in consumer_perf_testing.py


# Run the code on the terminal

python consumer_perf_testing.py 


# RESULTS
# Produced 1000000 messages
# Consumed 1000000 messages in 25.52 seconds
# 0.45 MB/sec
# 39182.18 messages/sec




















