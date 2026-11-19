
# Stage 1: Official Spark distribution
FROM apache/spark:3.5.9 AS spark-base

# Stage 2: Java 17 runtime
FROM eclipse-temurin:17-jre

USER root

# Install required runtime utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends tini && \
    rm -rf /var/lib/apt/lists/*

# Create Spark user
RUN groupadd --gid 185 spark && \
    useradd --uid 185 --gid 185 --create-home --shell /bin/bash spark

# Copy Spark installation and entrypoint
COPY --from=spark-base /opt/spark /opt/spark
COPY --from=spark-base /opt/entrypoint.sh /opt/entrypoint.sh

ENV SPARK_HOME=/opt/spark
ENV PATH=/opt/spark/bin:${PATH}

WORKDIR /opt/spark/work-dir

RUN mkdir -p /opt/spark-apps /opt/spark/work-dir

COPY target/scala-2.12/spark-kafka-iceberg.jar /opt/spark-apps/spark-kafka-iceberg.jar

# Permissions
RUN chown -R 185:0 /opt/spark /opt/spark-apps /opt/entrypoint.sh && \
    chmod +x /opt/entrypoint.sh

# IMPORTANT: Use Spark's Kubernetes entrypoint
ENTRYPOINT ["/opt/entrypoint.sh"]

USER 185
