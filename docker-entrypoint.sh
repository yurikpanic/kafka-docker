#!/bin/bash

set -e

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
    echo "zookeeper.connect=$KAFKA_ZOOKEEPER_CONNECT" >> $KAFKA_CONFIG
fi

# redirect all logs to console
sed -e 's/DailyRollingFileAppender/ConsoleAppender/g' /$KAFKA_DISTR/config/log4j.properties > /$KAFKA_DISTR/config/log4j-console-only.properties
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:/$KAFKA_DISTR/config/log4j-console-only.properties"
export KAFKA_GC_LOG_OPTS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps "

exec kafka-server-start.sh $KAFKA_CONFIG
