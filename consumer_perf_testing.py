from kafka import KafkaConsumer
from kafka import KafkaProducer

import time

topic = 'consumer_perf_tests'
msg_count = 1000000
msg_size = 100

payload = ('ABCDEFGHIJKLMNOPQRSTUVWXYZ' * 100).encode()[:msg_size]
bootstrap_servers = ['localhost:9092', 'localhost:9093', 'localhost:9094']


def produce_messages(topic, n_messages):
    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers, acks='all',
        compression_type='gzip')

    for _ in range(msg_count):
        producer.send(topic, payload)
        
    producer.flush()
        
    print(f"Produced {n_messages} messages")



def run_test(topic):
    consumer = KafkaConsumer(
        bootstrap_servers=bootstrap_servers, auto_offset_reset = 'earliest',
        group_id = None, fetch_min_bytes=50000, fetch_max_wait_ms=100,
        auto_commit_interval_ms=1000, session_timeout_ms=60000,
        heartbeat_interval_ms=20000, max_poll_interval_ms=700000,
        max_poll_records=1000
    )

    n_messages = 0
            
    consumer_start = time.time()

    consumer.subscribe([topic])
    
    for msg in consumer:
        n_messages += 1
        
        if n_messages >= msg_count:
            break
                    
    timing = time.time() - consumer_start

    consumer.close()    

    print(f"Consumed {n_messages} messages in {timing:.2f} seconds")

    print(f"{(len(msg) * n_messages) / timing / (1024*1024):.2f} MB/sec")

    print(f"{n_messages / timing:.2f} messages/sec")


if __name__ == "__main__":

    produce_messages(topic, msg_count)
    run_test(topic)


