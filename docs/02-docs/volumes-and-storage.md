---
title: Volumes and Storage
---

To ensure that your application's data is not lost, you will need to establish persistent storage when deploying it. By utilizing persistent storage, you can store the application data externally from the pod that runs the application. This storage approach allows you to retain the application data, even if the pod that the application runs on fails.

In Kubernetes, a persistent volume (PV) is a storage unit within the cluster, while a persistent volume claim (PVC) is a request for storage. To learn more about the functionality of PVs and PVCs, you can consult the official Kubernetes documentation on storage.

This page provides instructions on how to configure persistent storage using either a local storage provider or Longhorn.
