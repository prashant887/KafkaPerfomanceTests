
# On the consumer side, you can adjust the amount of data the consumer receives in each fetch response by tuning fetch.min.bytes (default is one), which specifies the minimum amount of data the broker should return in the fetch response, and the timeout on waiting for the data controlled by fetch.max.wait.ms (default is 500 ms). More data in fetch responses leads to less fetch requests. Batching on the producer side indirectly impacts both the number of produce and fetch requests, since the batch defines the minimum amount of data that can be fetched.

# When scaling consumers, keep in mind that all consumers in the same consumer group send offset commits and heartbeats to one broker, which acts as a consumer coordinator. More consumers in the consumer group increase the offset commit rate if offset commits are done on time intervals (auto.commit.interval.ms). Offset commits are essentially produce requests to the internal __consumer_offsets topic. Therefore, increasing the number of consumers in a consumer group may lead to additional request load on one broker, especially if commit intervals are configured to be small.

# -----------OPEN config/consumer.properties----------- 
# Add this 3 line of code

### consumer_v1.properties

fetch.min.bytes=1

fetch.max.wait.ms=500

auto.commit.interval.ms=1000

# Here we are keeping fetch.min.bytes=1 and fetch.max.wait.ms=500 which is
# the default values
# We are reducing the auto commit interval to 1 second this will 
# increase the durablity in the consumer end



# Now run the below code in terminal

$ echo "-----------------RESULTS-----------------";
kafka-consumer-perf-test.sh \
--topic performance_tuning \
--bootstrap-server localhost:9092 \
--messages 25000 \
--consumer.config $KAFKA_HOME/config/consumer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(" = "))[]';
echo "------------------------------------------";


# We have found the below results

# -----------RESULT-----------
# start.time = 2022-10-18 18:48:37:010
# end.time = 2022-10-18 18:48:38:106
# data.consumed.in.MB = 24.4795
# MB.sec = 22.3353
# data.consumed.in.nMsg = 25067
# nMsg.sec = 22871.3504
# rebalance.time.ms = 561
# fetch.time.ms = 535
# fetch.MB.sec = 45.7561
# fetch.nMsg.sec = 46854.2056


--------------------------------------------------------


# -----------OPEN config/consumer.properties----------- 
# Replace this 3 line of code

### consumer_v1.properties

fetch.min.bytes=500000

fetch.max.wait.ms=2500

auto.commit.interval.ms=1000

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
# start.time = 2022-10-18 19:17:47:224
# end.time = 2022-10-18 19:17:53:158
# data.consumed.in.MB = 24.7510 -- same
# MB.sec = 4.1710 -- fallen a lot
# data.consumed.in.nMsg = 25345
# nMsg.sec = 4271.1493 -- again fallen a lot
# rebalance.time.ms = 571
# fetch.time.ms = 5363 -- much higher, takes longer to fetch message
# fetch.MB.sec = 4.6151 -- fallen
# fetch.nMsg.sec = 4725.8997 -- fallen


# These are the observation found from the result (see notes above)


# Change number of partitions in the topic

kafka-topics.sh --bootstrap-server localhost:9092 \
--alter --topic performance_tuning \
--partitions 3


# -----------OPEN config/consumer.properties----------- 
# Replace this 1 line of code default for this is 1048576

# IMPORTANT: Remove the other properties fetch.min.bytes, getch.max.wait.ms, auto.commit.interval.ms

### consumer_v1.properties

max.partition.fetch.bytes=1000

# max.partition.fetch.bytes is a configuration parameter in Apache Kafka 
# that controls the maximum amount of data that a consumer can fetch in a 
# single request from a single partition

# Now run the below code in terminal

echo "-----------------RESULTS-----------------";
kafka-consumer-perf-test.sh \
--topic performance_tuning \
--bootstrap-server localhost:9092 \
--messages 25000 \
--consumer.config $KAFKA_HOME/config/consumer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(" = "))[]';
echo "------------------------------------------";


# start.time = 2023-03-21 15:47:06:268
# end.time = 2023-03-21 15:47:08:535
# data.consumed.in.MB = 24.5313
# MB.sec = 10.8210
# data.consumed.in.nMsg = 25120
# nMsg.sec = 11080.7234
# rebalance.time.ms = 1389
# fetch.time.ms = 878
# fetch.MB.sec = 27.9399
# fetch.nMsg.sec = 28610.4784






# -----------OPEN config/consumer.properties----------- 
# Replace this 1 line of code

### consumer_v1.properties

max.partition.fetch.bytes=1000


# note the 1048576 is the default for max.partition.fetch.bytes


# Now run the below code in terminal
$ echo "-----------------RESULTS-----------------";
kafka-consumer-perf-test.sh \
--topic performance_tuning \
--bootstrap-server localhost:9092 \
--messages 25000 \
--consumer.config $KAFKA_HOME/config/consumer.properties| \
jq -R .|jq -sr 'map(./", ")|transpose|map(join(" = "))[]';
echo "------------------------------------------";

# start.time = 2023-03-21 15:54:02:720
# end.time = 2023-03-21 15:54:04:718
# data.consumed.in.MB = 24.5313
# MB.sec = 12.2779
# data.consumed.in.nMsg = 25120
# nMsg.sec = 12572.5726
# rebalance.time.ms = 1524
# fetch.time.ms = 474
# fetch.MB.sec = 51.7537
# fetch.nMsg.sec = 52995.7806


# Hard to see any real change here, but will need many more fetch requests


