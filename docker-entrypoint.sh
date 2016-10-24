#!/bin/bash

set -e

# Allow the container to be started with `--user`
if [ "$1" = 'kafka-server-start.sh' -a "$(id -u)" = '0' ]; then
    chown -R "$KAFKA_USER" "$KAFKA_DATA" "/$KAFKA_DISTR"
    exec su-exec "$KAFKA_USER" "$0" "$@"
fi

echo "broker.id=$KAFKA_BROKER_ID" >> $KAFKA_CONFIG
echo "listeners=$KAFKA_LISTENERS" >> $KAFKA_CONFIG
if [ ! -z $KAFKA_ADVERTISED_LISTENERS ]; then
    echo "advertised.listeners=$KAFKA_ADVERTISED_LISTENERS" >> $KAFKA_CONFIG
fi
echo "log.dirs=$KAFKA_DATA" >> $KAFKA_CONFIG
echo "log.retention.hours=$KAFKA_LOG_RETENTION_HOURS" >> $KAFKA_CONFIG
echo "log.segment.bytes=$KAFKA_LOG_SEGMENT_BYTES" >> $KAFKA_CONFIG
echo "zookeeper.connect=$KAFKA_ZOOKEEPER_CONNECT" >> $KAFKA_CONFIG

exec kafka-server-start.sh $KAFKA_CONFIG
