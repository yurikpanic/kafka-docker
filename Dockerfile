FROM openjdk:8-jre-alpine
MAINTAINER Iurii Vyshnevskyi <vishnevsky@gmail.com>

RUN apk add --no-cache \
    bash \
    su-exec

ENV KAFKA_USER=kafka \
    KAFKA_DATA=/kafka-logs \
    KAFKA_BROKER_ID=0 \
    KAFKA_ADVERTISED_LISTENERS="" \
    KAFKA_LOG_RETENTION_HOURS=168 \
    KAFKA_LOG_SEGMENT_BYTES=1073741824 \
    KAFKA_ZOOKEEPER_CONNECT=zoo:2181/kafka

RUN set -x \
    && adduser -D "$KAFKA_USER" \
    && mkdir -p "$KAFKA_DATA" \
    && chown "$KAFKA_USER:$KAFKA_USER" "$KAFKA_DATA"

ARG KAFKA_VERSION=0.10.1.0
ARG KAFKA_SCALA_VERSION=2.11
ENV KAFKA_DISTR=kafka_$KAFKA_SCALA_VERSION-$KAFKA_VERSION
ENV KAFKA_CONFIG="/$KAFKA_DISTR/config/server.properties"

RUN set -x \
    && wget -q "http://www.apache.org/dist/kafka/$KAFKA_VERSION/$KAFKA_DISTR.tgz" \
    && tar -zxpf "$KAFKA_DISTR.tgz" \
    && rm -r "$KAFKA_DISTR.tgz" \
    && chown -R "$KAFKA_USER:$KAFKA_USER" "$KAFKA_DISTR"

WORKDIR "$KAFKA_DISTR"
VOLUME "$KAFKA_DATA"

EXPOSE 9092

ENV PATH=$PATH:/$KAFKA_DISTR/bin

COPY docker-entrypoint.sh /
CMD ["/docker-entrypoint.sh"]

