# max.poll.records simply defines the maximum number of records returned in a single call to poll().

# Now max.poll.interval.ms defines the delay between the calls to poll().

# max.poll.interval.ms: The maximum delay between invocations of poll() when using consumer group management. This places an upper bound on the amount of time that the consumer can be idle before fetching more records. If poll() is not called before expiration of this timeout, then the consumer is considered failed and the group will rebalance in order to reassign the partitions to another member. For consumers using a non-null group.instance.id which reach this timeout, partitions will not be immediately reassigned. Instead, the consumer will stop sending heartbeats and partitions will be reassigned after expiration of session.timeout.ms. This mirrors the behavior of a static consumer which has shutdown.

# If you want to ensure that consumers in a consumer group are constantly processing messages within a certain interval you may use these properties to configure the interval

 # You can tune both in order to get to the expected behaviour. For example, you could compute the average processing time for the messages. If the average processing time is say 1 second and you have max.poll.records=100 then you should allow approximately 100+ seconds for the poll interval.


# -----------OPEN config/consumer.properties----------- 
### consumer_v2.properties
# Add this two line of code (remove all the other properties)

max.poll.interval.ms=10

max.poll.records=500

# max.poll.interval.ms is the interval to check the consumer is continuing 
# to process messages. If the consumer application does not make a call 
# to poll at least every max.poll.interval.ms milliseconds, 
# the consumer is considered to be failed, causing a rebalance
# max.poll.records is the number of processed records returned from the consumer





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
# [2022-10-18 19:31:23,067] WARN [Consumer clientId=perf-consumer-client, groupId=perf-consumer-70488] consumer poll timeout has expired. This means the time between subsequent calls to poll() was longer than the configured max.poll.interval.ms, which typically implies that the poll loop is spending too much time processing messages. You can address this either by increasing max.poll.interval.ms or by reducing the maximum size of batches returned in poll() with max.poll.records. (org.apache.kafka.clients.consumer.internals.ConsumerCoordinator)
# [2022-10-18 19:31:23,088] WARN [Consumer clientId=perf-consumer-client, groupId=perf-consumer-70488] Synchronous auto-commit of offsets {performance_tuning-8=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}, performance_tuning-9=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}, performance_tuning-6=OffsetAndMetadata{offset=500, leaderEpoch=0, metadata=''}, performance_tuning-7=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}, performance_tuning-4=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}, performance_tuning-5=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}, performance_tuning-2=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}, performance_tuning-3=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}, performance_tuning-0=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}, performance_tuning-1=OffsetAndMetadata{offset=0, leaderEpoch=null, metadata=''}} failed: Offset commit cannot be completed since the consumer is not part of an active group for auto partition assignment; it is likely that the consumer was kicked out of the group. (org.apache.kafka.clients.consumer.internals.ConsumerCoordinator)
# start.time = 2022-10-18 19:31:22:461
# end.time = 2022-10-18 19:31:23:507
# data.consumed.in.MB = 24.7246
# MB.sec = 23.6373
# data.consumed.in.nMsg = 25318
# nMsg.sec = 24204.5889
# rebalance.time.ms = 516
# fetch.time.ms = 530
# fetch.MB.sec = 46.6502
# fetch.nMsg.sec = 47769.8113



# These are the observation found from the result

# We get a bunch of warning to increasing max.poll.interval.ms or by reducing 
# the maximum size of batches returned in poll() with max.poll.records




# -----------OPEN config/consumer.properties----------- 
### consumer_v2.properties
# Replace this two line of code

max.poll.interval.ms=700000

max.poll.records=1000




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
# start.time = 2022-10-18 19:36:05:607
# end.time = 2022-10-18 19:36:06:611
# data.consumed.in.MB = 24.6836
# MB.sec = 24.5853
# data.consumed.in.nMsg = 25276
# nMsg.sec = 25175.2988
# rebalance.time.ms = 539
# fetch.time.ms = 465
# fetch.MB.sec = 53.0830
# fetch.nMsg.sec = 54356.9892




# Now lets find the end-to-end latency between when the producer has produced
# the message and when it is consumed by the consumer

$ kafka-run-class.sh kafka.tools.EndToEndLatency --help

# Here we get the syntax of the EndToEndLatency
# broker_list topic num_messages producer_acks message_size_bytes [optional] properties_file




$ kafka-run-class.sh kafka.tools.EndToEndLatency \
localhost:9092 \
performance_tuning 25000 all 1024

# Here we are getting an average latency of about 1.77 ms