# Real-Time IoT Sensor Streaming Pipeline on Kubernetes

A real-time data engineering project that ingests IoT sensor events from Apache Kafka, processes them using Scala and Apache Spark Structured Streaming, and stores the results in Apache Iceberg tables running on Kubernetes.

## Architecture

```text
IoT Sensor Events (JSON)
          |
          v
     Apache Kafka
     Topic: sensor-data
          |
          v
 Apache Spark Structured Streaming
       (Scala 2.12)
          |
          v
     JSON Parsing
          |
          v
   Data Transformation
          |
          v
   Apache Iceberg Table
          |
          v
  Persistent Kubernetes Storage
```

## Technologies Used

| Technology | Version / Details |
|---|---|
| Scala | 2.12.18 |
| Apache Spark | 3.5.9 |
| Apache Kafka | 3.9.1 |
| Apache Iceberg | 1.12.0 |
| Java | 17 |
| SBT | 1.9.9 |
| sbt-assembly | 2.3.0 |
| Docker | Containerization |
| Kubernetes | Docker Desktop Kubernetes |
| Storage | Kubernetes PVC |

## Project Structure

```text
k8s-spark-streaming/
│
├── src/
│   └── main/
│       └── scala/
│           └── com/
│               └── demo/
│                   └── SensorStreamingApp.scala
│
├── project/
│   └── plugins.sbt
│
├── k8s/
│   ├── kafka.yaml
│   ├── spark-rbac.yaml
│   ├── spark-submitter.yaml
│   └── streaming-storage.yaml
│
├── Dockerfile
├── build.sbt
├── .gitignore
└── README.md
```

## Data Processing

1. Kafka receives IoT sensor events in JSON format.
2. Spark Structured Streaming consumes messages from the `sensor-data` topic.
3. Incoming JSON messages are parsed using an explicitly defined schema.
4. Sensor fields are transformed into the target table schema.
5. Invalid records with null device IDs are filtered out.
6. Processed records are written to Apache Iceberg in append mode.
7. Streaming checkpoints and offsets are persisted on Kubernetes storage.

### Sample Input

```json
{"deviceId":"sensor-001","temperature":25.5,"eventTime":"2026-11-19T18:20:00"}
{"deviceId":"sensor-002","temperature":28.1,"eventTime":"2026-11-19T18:20:05"}
```

### Iceberg Table

**Table:** `local.iot.sensor_readings`

| Column | Data Type |
|---|---|
| device_id | STRING |
| temperature | DOUBLE |
| event_time | TIMESTAMP |

## Storage and Checkpointing

The project uses a Kubernetes PersistentVolumeClaim:

- PVC: `streaming-data`
- Requested storage: 5Gi
- Access mode: ReadWriteOnce

Storage locations:

- Iceberg warehouse: `/data/warehouse`
- Streaming checkpoint: `/data/checkpoints/sensor-readings`

The Iceberg warehouse uses a Hadoop catalog backed by persistent filesystem storage.

## Build the Application

Build the assembly JAR using SBT:

```powershell
sbt clean assembly
```

Generated JAR:

```text
target/scala-2.12/spark-kafka-iceberg.jar
```

## Build and Push Docker Image

Build the Docker image:

```powershell
docker build -t shobika25/spark-kafka-iceberg:1.4 .
```

Push it to Docker Hub:

```powershell
docker push shobika25/spark-kafka-iceberg:1.4
```

The custom image uses Java 17 and the Spark 3.5.9 distribution.

## Kubernetes Deployment

Create the namespace:

```powershell
kubectl create namespace streaming
```

Apply the Kubernetes resources:

```powershell
kubectl apply -f k8s/streaming-storage.yaml
kubectl apply -f k8s/kafka.yaml
kubectl apply -f k8s/spark-rbac.yaml
kubectl apply -f k8s/spark-submitter.yaml
```

Verify the resources:

```powershell
kubectl get pods -n streaming
kubectl get services -n streaming
kubectl get pvc -n streaming
```

## Validation and Testing

The following validations were successfully completed during the project:

- Kafka broker deployed and running in Kubernetes.
- Kafka topic `sensor-data` created.
- Spark driver and executor successfully started.
- Spark application connected to Kafka.
- Sensor JSON events processed by Structured Streaming.
- Iceberg namespace and table created.
- Four sensor records successfully written to Iceberg.
- Multiple Iceberg snapshots generated.
- Streaming checkpoint and offset files persisted.
- Iceberg table schema verified using Spark SQL.

### Verify Iceberg Table

```sql
SHOW NAMESPACES IN local;

SHOW TABLES IN local.iot;

DESCRIBE TABLE local.iot.sensor_readings;

SELECT * FROM local.iot.sensor_readings;

SELECT * FROM local.iot.sensor_readings.snapshots;
```

### Verified Results

| Validation | Result |
|---|---|
| Kafka deployment | Successful |
| Spark driver | Successful |
| Spark executor | Successful |
| Iceberg table creation | Successful |
| Sensor records written | 4 |
| Iceberg snapshots | 4 |
| Checkpoint files | Verified |
| Table schema | Verified |

## Key Learning Outcomes

- Implementing real-time ingestion using Apache Kafka.
- Building streaming applications with Scala and Spark Structured Streaming.
- Parsing and transforming JSON event data.
- Integrating Spark Structured Streaming with Apache Iceberg.
- Deploying Spark applications on Kubernetes.
- Building custom Spark Docker images.
- Configuring Kubernetes RBAC and persistent storage.
- Understanding streaming checkpoints, offsets, and Iceberg snapshots.

## Future Enhancements

- Add schema validation and malformed-record handling.
- Implement monitoring and alerting.
- Add automated deployment using CI/CD.
- Introduce multiple sensor event types.
- Explore recovery and restart behavior under failure scenarios.

---

**Project:** Real-Time IoT Sensor Streaming Pipeline  
**Author:** Shobika  
**Focus:** Data Engineering | Real-Time Streaming | Distributed Processing
