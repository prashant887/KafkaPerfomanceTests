
# Show the total size of the log files generated so far

du -ch /tmp/kafka-logs-*

# In my case i have 2GB in logs

# replace all log.retention.hours with log.retention.ms
# log.cleaner.backoff.ms is the amount of time to sleep 
# when there are no logs to clean

# Change the properties in all 3 broker files server-0, server-1, server-2

------------
# The following configurations control the disposal of log segments. The policy can
# be set to delete segments after a period of time, or after a given size has accumulated.
# A segment will be deleted whenever *either* of these criteria are met. Deletion always happens
# from the end of the log.

# The minimum age of a log file to be eligible for deletion due to age
log.retention.ms=120000

# A size-based retention policy for logs. Segments are pruned from the log unless the remaining
# segments drop below log.retention.bytes. Functions independently of log.retention.hours.
#log.retention.bytes=1073741824

# The maximum size of a log segment file. When this size is reached a new log segment will be created.
#log.segment.bytes=1073741824

# The interval at which log segments are checked to see if they can be deleted according
# to the retention policies
log.retention.check.interval.ms=10000

log.cleaner.backoff.ms=30000
-------------



# Here we have set the log retention period to 2 minutes and 
# we will be keep checking for retention for every 10 seconds
# This will control the size of the data on the disk and delete obsolete data
# Limit maintenance work on the Kafka Cluster


# IMPORTANT: Kill and restart all the brokers!


# Run the below command


du -ch /tmp/kafka-logs-*

# It is still 1GB in logs


#### After about 3 minutes passing run the below command

du -ch /tmp/kafka-logs-*

# We are getting about 1MB in logs










