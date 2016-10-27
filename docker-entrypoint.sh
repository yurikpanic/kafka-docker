#!/bin/bash

set -e

if [ "$(id -u)" = '0' ]; then
    exec su-exec "$KAFKA_USER" "$0" "$@"
fi

if [ ! -f $KAFKA_CONFIG ]; then
    if [ ! -z $KAFKA_BROKER_ID ]; then
        echo "broker.id=$KAFKA_BROKER_ID" >> $KAFKA_CONFIG
    fi
    if [ ! -z $KAFKA_ADVERTISED_LISTENERS ]; then
        echo "advertised.listeners=$KAFKA_ADVERTISED_LISTENERS" >> $KAFKA_CONFIG
    fi
    echo "log.dirs=$KAFKA_DATA" >> $KAFKA_CONFIG
    if [ ! -z $KAFKA_LOG_RETENTION_HOURS ]; then
        echo "log.retention.hours=$KAFKA_LOG_RETENTION_HOURS" >> $KAFKA_CONFIG
    fi
    if [ ! -z $KAFKA_LOG_SEGMENT_BYTES ]; then
        echo "log.segment.bytes=$KAFKA_LOG_SEGMENT_BYTES" >> $KAFKA_CONFIG
    fi
    if [ ! -z $KAFKA_NUM_PARTITIONS ]; then
        echo "num.partitions=$KAFKA_NUM_PARTITIONS" >> $KAFKA_CONFIG
    fi
    if [ ! -z $KAFKA_DEFAULT_REPLICATION_FACTOR ]; then
        echo "default.replication.factor=$KAFKA_DEFAULT_REPLICATION_FACTOR" >> $KAFKA_CONFIG
    fi

    echo "zookeeper.connect=$KAFKA_ZOOKEEPER_CONNECT" >> $KAFKA_CONFIG
fi

# redirect all logs to console
sed -e 's/DailyRollingFileAppender/ConsoleAppender/g' \
    -e 's/TRACE/INFO/g' \
    -e 's/DEBUG/INFO/g' \
    /$KAFKA_DISTR/config/log4j.properties > /$KAFKA_DISTR/config/log4j-console-only.properties
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:/$KAFKA_DISTR/config/log4j-console-only.properties"
# override gc log settings in kafka-run-class.sh
export KAFKA_GC_LOG_OPTS="-Dnot.used=42"

exec kafka-server-start.sh $KAFKA_CONFIG
