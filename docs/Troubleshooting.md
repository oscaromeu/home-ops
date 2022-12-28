# 🛠️ Troubleshooting

### ♻️ Force Reconcile

```sh
flux reconcile -n flux-system source git flux-cluster
flux reconcile -n flux-system kustomization flux-cluster
```

### 📂 Troubleshooting volume with multipath

Issue: If you are getting pods that will not start due to timeout issues. You may also see the `share-manager-pvc-xxx` pods crashing and restarting over and over again. If this is your issue(s), look into this first.

- [Official Longhorn Troubleshooting Documentation](https://longhorn.io/kb/troubleshooting-volume-with-multipath/)

### 📡Renaming Network Interface

Issue: If your network interface does not match your other nodes, you can change it. This is useful if you are using Ansible and expect all network interfaces to be the same.

- [Change Network Interface Name](https://serverfault.com/a/941659/309600)

---
