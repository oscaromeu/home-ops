## Loki Architecture

It consists of three main components:

+ Loki: the log data store and indexer. This component is responsible for receiving, parsing, and indexing log data. It stores log data in a highly compressed format, using a custom storage format called "chunks". The chunks are organized in a way that allows for efficient querying and retrieval of log data.
+ Promtail: the log data scraper. This component is responsible for collecting log data from various sources and sending it to Loki. It can scrape logs from files, Kubernetes pods, and other sources. Promtail supports various log formats, such as JSON, text, and protobuf, and it can automatically detect and parse the log format.
+ Grafana: the visualization and alerting tool. This component can be used to query and visualize logs stored in Loki. Grafana supports a powerful query language and allows you to create rich visualizations and alerts based on your log data.
Loki stores data in a distributed fashion, it means that it stores the logs in multiple machines, this is done to ensure that the system can handle high data volume, high query rates and high availability.

Promtail, on the other hand, can be deployed in multiple instances and it can scrape logs from multiple sources, it also run as a sidecar container along with the service or application that generates logs, which makes it easy to deploy and manage.
