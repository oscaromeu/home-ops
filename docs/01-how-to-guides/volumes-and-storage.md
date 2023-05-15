---
title: Volumes and Storage
---

## Backup and restore

### Postgres Backup with Barman

```yaml
---
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: postgres
  namespace: default
spec:
  schedule: "@weekly"
  immediate: true
  backupOwnerReference: self
  cluster:
    name: postgres
```

### Schedule a periodic full backup

```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: full
  namespace: velero
spec:
  schedule: 0 4 * * *
  template:
    hooks: {}
    includedNamespaces:
    - 'default'
    #included_resources:
    #- '*'
    labelSelector:
      matchLabels:
        app: velero
        component: server
    includeClusterResources: true
    metadata:
      labels:
        type: 'full'
        schedule: 'daily'
    ttl: 720h0m0s
```

## Resources

+ [https://velero.io/docs/v1.3.0/api-types/schedule/](https://velero.io/docs/v1.3.0/api-types/schedule/)
+ [CloudNativePG API reference](https://cloudnative-pg.io/documentation/1.20/api_reference/)
