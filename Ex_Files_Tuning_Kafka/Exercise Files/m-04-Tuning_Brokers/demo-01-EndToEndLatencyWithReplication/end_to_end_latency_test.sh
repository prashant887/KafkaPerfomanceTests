-----------------------------------------------------------
# Measuring the end-to-end latency with 1 broker and no replication

# Open terminal

# Start the zookeeper in one terminal
# Terminal 1 - tab 1:

zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties

# Terminal 1 - tab 2:

kafka-server-start.sh $KAFKA_HOME/config/server-0.properties

# IMPORTANT: Please note that we have Zookeeper and 1 broker running


# Move this over to another screen and open up a new terminal for latency tests

------------------------------------

# In Sublimetext open up the server-0.properties file and scroll show 
# the default broker configuraton


# Open up another terminal (Terminal - 2)


# Create a new topic will have partitions = 3 and replication set to 1
kafka-topics.sh --create \
--topic broker_tuning \
--bootstrap-server localhost:9092 \
--partitions 3


# Describes the topic in this case the topic name is broker_tuning

kafka-topics.sh --describe \
--topic broker_tuning \
--bootstrap-server localhost:9092

# Show help for kafka-run-class.sh 

kafka-run-class.sh --help


# Use this to compute end-to-end latency

kafka-run-class.sh kafka.tools.EndToEndLatency \
localhost:9092 \
broker_tuning 25000 all 1024

# Here we are getting an average latency of about 1.58 ms


-------------------------------------
# NOTES:

# Increase durability by increasing replication

# To increase the reliability and fault tolerance, replications of the partitions are necessary. Remember that topic replication does not increase the consumer parallelism. The factors to consider while choosing replication factor are:

# It should be at least 2 and a maximum of 4. The recommended number is 3 as it provides the right balance between performance and fault tolerance, and usually cloud providers provide 3 data centers / availability zones to deploy to as part of a region.

# The advantage of having a higher replication factor is that it provides a better resilience of your system. If the replication factor is N, up to N-1 broker may fail without impacting availability if acks=0 or acks=1 or N-min.insync.replicas brokers may fail if acks=all

# The disadvantages of having a higher replication factor:

# Higher latency experienced by the producers, as the data needs to be replicated to all the replica brokers before an ack is returned if acks=all

# More disk space required on your system


# We can obviously increase the avalibility by increasing the replication 
# factor and insync replicas but it will take a hit on latency as it is
# extra work

----------------------------
# Now go back to the Terminal and Tabs where Zookeeper and the Broker is running

# Show Tab 1 - Zookeeper running

# Show Tab 2 - Broker 0 running

# Show Tab 3 - Run Broker 1

kafka-server-start.sh $KAFKA_HOME/config/server-1.properties

# Show Tab 4 - Run Broker 2

kafka-server-start.sh $KAFKA_HOME/config/server-2.properties


# We now have a cluster with 3 brokers

------------------------------

# Since we already have the topic we cannot increase the replication factor
# and isr on the fly using the --alter command

### Create a new folder in $KAFKA_HOME

mkdir $KAFKA_HOME/topic_config


### Create and open the file in nano

touch $KAFKA_HOME/topic_config/topic_config.json

nano $KAFKA_HOME/topic_config/topic_config.json


# High availability environments require a replication factor of at least 3 for topics and a minimum number of in-sync replicas as 1 less than the replication factor. For increased data durability, set min.insync.replicas in your topic configuration and message delivery acknowledgments using acks=all in your producer configuration.


### topic_config_v1.json

{
     "version":1,
     "partitions":[
          {"topic":"broker_tuning","partition":0,"replicas":[0,1,2]},
          {"topic":"broker_tuning","partition":1,"replicas":[0,1,2]},
          {"topic":"broker_tuning","partition":2,"replicas":[0,1,2]}
     ]
}

# Save the file

# Here we are having the default 3 partitions and 3 replicas

# Run in terminal

kafka-reassign-partitions.sh \
--bootstrap-server localhost:9092, localhost:9093, localhost:9094 \
--reassignment-json-file $KAFKA_HOME/topic_config/topic_config.json \
--execute

# Describes the topic in this case the topic name is broker_tuning

kafka-topics.sh --describe \
--topic broker_tuning \
--bootstrap-server localhost:9092

# Observe now we have 3 replicas and 4 isr


kafka-run-class.sh kafka.tools.EndToEndLatency \
localhost:9092 \
broker_tuning 25000 all 1024


# Here we are getting an average latency of about 2.28 ms
# https://www.conduktor.io/kafka/kafka-topics-choosing-the-replication-factor-and-partitions-count#How-to-choose-the-replication-factor-of-a-Kafka-topic?-1
# In production it is always recomended to have at least 3 replics




