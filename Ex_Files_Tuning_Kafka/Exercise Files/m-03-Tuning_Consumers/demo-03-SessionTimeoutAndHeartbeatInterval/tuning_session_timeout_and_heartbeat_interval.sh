# heartbeat.interval.ms is the duration within which consumer sends signal to kafka broker to indicate it is alive, session.timeout.ms is the maximum duration that kafka broker can wait without a receiving heartbeat from consumer, if session.timeout.ms duration exceeds without receiving a heartbeat from consumer than that consumer will be marked as dead(i.e.it can no more consume message). 

# In a kafka queue where millions of messages processing a day can have more session.timeout.ms duration say upto 30000ms( default is 10s) to keep consumer alive while processing huge volume.

# -----------OPEN config/consumer.properties----------- 

# Add this config property for the consumer (get rid of all previous properties)

session.timeout.ms=10

# We are setting the above properties to fetch.min.bytes=50000 and fetch.max.wait.ms=100
# also we are setting session.timeout.ms=10
# Specifies the maximum amount of time in milliseconds a consumer 
# within a consumer group can be out of contact with a broker before 
# being considered inactive and a rebalancing is triggered between the 
# active consumers in the group

# Now run the below code in terminal

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
# Exception in thread "main" org.apache.kafka.common.KafkaException: Failed to construct kafka consumer
# 	at org.apache.kafka.clients.consumer.KafkaConsumer.<init>(KafkaConsumer.java:823)
# 	at org.apache.kafka.clients.consumer.KafkaConsumer.<init>(KafkaConsumer.java:664)
# 	at org.apache.kafka.clients.consumer.KafkaConsumer.<init>(KafkaConsumer.java:645)
# 	at org.apache.kafka.clients.consumer.KafkaConsumer.<init>(KafkaConsumer.java:625)
# 	at kafka.tools.ConsumerPerformance$.main(ConsumerPerformance.scala:55)
# 	at kafka.tools.ConsumerPerformance.main(ConsumerPerformance.scala)
# Caused by: java.lang.IllegalArgumentException: Heartbeat must be set lower than the session timeout
# 	at org.apache.kafka.clients.consumer.internals.Heartbeat.<init>(Heartbeat.java:44)
# 	at org.apache.kafka.clients.consumer.internals.AbstractCoordinator.<init>(AbstractCoordinator.java:165)
# 	at org.apache.kafka.clients.consumer.internals.ConsumerCoordinator.<init>(ConsumerCoordinator.java:155)
# 	at org.apache.kafka.clients.consumer.KafkaConsumer.<init>(KafkaConsumer.java:788)
# 	... 5 more



# These are the observation found from the result

# We get an error because we have set the session.timeout to about 10ms
# It is better to increase this value to reduce falure from 
# the consumer part




# -----------OPEN config/consumer.properties----------- 
### consumer_v2.properties
# Add this two line of code

session.timeout.ms=60000

heartbeat.interval.ms=20000

# heartbeat.interval.ms Specifies the interval in milliseconds between 
# heartbeat checks to the consumer group coordinator to indicate that 
# a consumer is active and connected
# heartbeat interval must be lower, usually by a third, 
# than the session timeout interval




# Now run the below code in terminal

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
# Works fine
# start.time = 2022-10-18 19:20:29:727
# end.time = 2022-10-18 19:20:30:728
# data.consumed.in.MB = 24.6836
# MB.sec = 24.6589
# data.consumed.in.nMsg = 25276
# nMsg.sec = 25250.7493
# rebalance.time.ms = 511
# fetch.time.ms = 490
# fetch.MB.sec = 50.3747
# fetch.nMsg.sec = 51583.6735
