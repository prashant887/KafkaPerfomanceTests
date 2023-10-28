***Producer Tuning***

**Partitions**

1 Partition 1 Replication
10 Partition 1 Replications : Better perf , more throughput and latency 
100 Partition 1 Replication : High Throughput , but almost as 10 Partition , latency increased 

Increasing Partitions improved throughput 

Too many partitions negative affect on e2e latency , more partitions leads to less batching 
on produces and more partitions per broker lead to more overahed 
per replica follower fetch request , too many partitions leads to large commit time
on brokers and high CPU loads , more queuing delays 

**Replicas** : 

Increases Data Durability but lowers latency 
Fewer replicas reduces durability , increases availability 

Topic 1 partition replication factor 1 ,2 and 3 
With Replication Factor 2 Through Put is decreasaed 
MB/Sec is dec , Avg Latency increased 

3 Replication Throught Put is decared , latency increased 

it increases durablity , acks=all , increases latency and throuhput 

**ACKS**

Acks from Brokers who hold partitions and replicas
decreases avilablity
acks=0 : No Acc Needed
acks=1 : Ack from Patition leader
acks=-1/all : All replicas or ISR's 

Replication factor 3 , 1 partition 
acks=0 

ack=1:Decrease through put , increase latency 

ack=all : Fallen Throuh put , Increase latency 

**Compression** 

No compression by default , over all increases processing overahead
might dec end to end over all latency , network latency 

Process Overahed on producer to compress message
Process Overahed on broker to decompress and compress messaege for validation
Porcess overhead on consumer to uncompress

**Batch Size and Lingring MS**

Increase Linger MS reduces latency 

Batch Size:16K Linger:0 -> Less Number of Batches  , more through put
Batch Size 2.5K Linger 0: High Number of Batches , less through put , latency increased 

Linger:0 less through put more latency
Linger:10MS , to increase batch size : Increase throughput  , better latency
Batch 25k , Linger 100MS : Better throughput , decrease latency 


Increase Batch size and add compression 
Better throuh put and latency 

**Message count and size**

total number of messages sent without throtteling,payload size,default batch size
larger recs more batches
Num Recs:25k Rec Size:1000KB : Good Through Put
Num Recs:25k Rec Size:10000KB :  Through Put has fallen , rec/secs , increase latency 
Num Recs:25k Rec Size:100000KB :  Through Put has increased , rec/secs , increase latency  increase with batch size

***Consumer Perf Test***
Consumer Properties 
fetch.min.bytes=1 : Fetch as soon as single byte of data is avilable
fetch.max.wait.ms=500: Fetch data after a time-out in millisecs 
auto.commit.interval.ms=1000

Lower values of 1 and 2 faster the message consumption 

3 Message will be committed more often increases durablity , recues avliablity 

Reduced in messages consumed , per sec 
fetch time increased 
reduced through put 

max.partition.fetch.bytes -> smaller the value more frequent fetch

**Session Timeout and Heartbeat**

session.timeout.ms -> Max time broker can wait without Heartbeat from CConsumer
=10ms m HB(3s) should be less than timeout 

heartbeat.interval.ms=2000ms (20 s)

**Max Poll Interval and Max Poll Recs**

max.poll.interval.ms:Max delay b/w poll invocations when using consumer group management,upper bond on consuer can be ideal before trying next fetch,value shdnt be too short,if dosnt respond consumer is assumed dated
max.poll.records:Recs fetched for every poll

***Tuning Kafka Brokers***

**Replication Factor**

