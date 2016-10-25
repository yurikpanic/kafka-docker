# kafka-docker

An image to run apache kafka

## How to use

### From commandline

    $ docker run --name zoo -d --restart unless-stopped -p 2181:2181 zookeeper:3.4
    $ docker run --name kafka -d --restart unless-stopped --link zoo -p 9092:9092 yurikpanic/kafka-docker

### From docker-compose

```yaml
version: '2'
services:
  zoo:
    image: zookeeper:3.4
    restart: unless-stopped
    ports:
      - 2181
  kafka1:
    image: yurikpanic/kafka-docker
    restart: unless-stopped
    depends_on:
      - zoo
    environment:
      KAFKA_BROKER_ID: 0
      KAFKA_ZOOKEEPER_CONNECT: zoo:2181/kafka
  kafka2:
    image: yurikpanic/kafka-docker
    restart: unless-stopped
    depends_on:
      - zoo
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zoo:2181/kafka
```

## Environment variables

### `KAFKA_BROKER_ID`

Defaults to `0`. Kafka's `broker.id` parameter.

### `KAFKA_ZOOKEEPER_CONNECT`

Defaults to `zoo:2181/kafka`. Kafka's `zookeeper.connect` parameter.

### `KAFKA_LOG_RETENTION_HOURS`

Defaults to `168`. Kafka's `log.retention.hours` parameter.

### `KAFKA_LOG_SEGMENT_BYTES`

Defaults to `1073741824`. Kafka's `log.segment.bytes` parameter.

### `KAFKA_ADVERTISED_LISTENERS`

No default value, container hostname will be used. Kafka's `advertised.listeners` parameter.

### `KAFKA_DATA`

Defaults to `/kafka-logs`. Location for kafka logs to be stored. Kafka's `log.dirs` parameter.
This is also a container volume.

### `KAFKA_USER`

Defaults to `kafka`. A user under which kafka will be started inside the container

