# Go to https://kafka.apache.org/downloads
# Download the latest kafka (3.4) Scala 2.12

Scala 2.12  - kafka_2.12-3.4.0.tgz (asc, sha512)

# Extract the downloaded .zip 

# Open a terminal

pwd
# Check the current working directory in my case the home directory

mkdir tools
# CReate a folder called tools

ls -l
# List all the files and directory

mv ~/Downloads/kafka_2.12-3.4 ~/tools/
# Moving the extracted folder from downloads to tools

nano ~/.bash_profile

# Add the below code
export KAFKA_HOME=$HOME/tools/kafka_2.12-3.4        
export PATH="$KAFKA_HOME/bin:$PATH"

# Save and exit

source ~/.bash_profile


---------------------------------------
# Starting Zookeeper and the Kafka server


# Open a terminal

# Start the zookeeper in one terminal
# Terminal 1 - tab 1:

zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties

# Open another terminal for running the broker service
# Terminal 1 - tab 2:

kafka-server-start.sh $KAFKA_HOME/config/server.properties
# Now the zookeeper and broker server running 

# The previous two terminals can be in the background - on another screen

---------------------------------------

# IMPORTANT!!!!
# Now the producer and consumer terminals should be opened up side-by-side


# Open up another terminal (Terminal - 2) - Producer

# Let's create our first topic  

kafka-topics.sh --create --topic "loony_topic" \
--bootstrap-server localhost:9092 

# We can list all the topics within the server

kafka-topics.sh --list --bootstrap-server localhost:9092

# We can also describe the topic

kafka-topics.sh --describe --topic "loony_topic" \
--bootstrap-server localhost:9092

kafka-console-producer.sh --topic loony_topic \
--bootstrap-server localhost:9092 

# Open another terminal (Terminal - 3) - Consumer

kafka-console-consumer.sh --topic loony_topic \
--bootstrap-server localhost:9092 

# let's try to publish one msg in the producer (Terminal - 2) 

Welcome to Kafka!

# We see the message is published in the consumer

# Publish another message

Does the second message get delivered?


# This message is also received by the consumer









