---
title: Backup and restore
---

## Schedule a periodic full backup

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
