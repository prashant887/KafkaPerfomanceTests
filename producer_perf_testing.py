from kafka import KafkaProducer
import time

topic = 'producer_perf_tests'
msg_count = 1000000
msg_size = 100

payload = ('ABCDEFGHIJKLMNOPQRSTUVWXYZ' * 100).encode()[:msg_size]
bootstrap_servers = ['localhost:9092', 'localhost:9093', 'localhost:9094']


def run_test(topic, n_messages, msg_size):
    # producer = KafkaProducer(
    #     bootstrap_servers=bootstrap_servers, acks='all',
    #     batch_size=25000, linger_ms=100)

    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers, acks='all',
        compression_type='gzip')

    producer_start = time.time()

    for _ in range(msg_count):
        producer.send(topic, payload)
        
    producer.flush()
        
    timing = time.time() - producer_start

    print(f"Processed {n_messages} messages in {timing:.2f} seconds")

    print(f"{(msg_size * n_messages) / timing / (1024*1024):.2f} MB/sec")

    print(f"{n_messages / timing:.2f} messages/sec")


if __name__ == "__main__":
    run_test(topic, msg_count, msg_size)
