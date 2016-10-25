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

# redirect all logs to console
sed -e 's/DailyRollingFileAppender/ConsoleAppender/g' /$KAFKA_DISTR/config/log4j.properties > /$KAFKA_DISTR/config/log4j-console-only.properties
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:/$KAFKA_DISTR/config/log4j-console-only.properties"
export KAFKA_GC_LOG_OPTS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps "

exec kafka-server-start.sh $KAFKA_CONFIG
