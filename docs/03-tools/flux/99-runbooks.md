## Helm rollback failed

### Meaning

There is an existing issue with the Flux helm-controller (https://github.com/fluxcd/helm-controller/issues/149) that can cause HelmReleases to get "stuck" with an error message like "Helm upgrade failed: another operation (install/upgrade/rollback) is in progress". This can happen anytime the helm-controller is restarted while a HelmRelease is upgrading/installing/etc.


### Mitigation

To ensure the HelmRelease error was caused by the helm-controller restarting, first try to suspend/resume the HelmRelease:

```
flux suspend hr <helmrelease> -n <namespace>
flux resume hr <helmrelease> -n <namespace>
```

You can find any flux resource that is not ready by running

```
flux get all -A --status-selector ready=false
```

#### Scenario A

After applying suspend/resume the issue is solved and a message with "Release reconciliation succeeded" appears.

**Example**

```
➜  ~ flux get all -A --status-selector ready=false
NAMESPACE       NAME    REVISION        SUSPENDED       READY   MESSAGE

NAMESPACE       NAME    REVISION        SUSPENDED       READY   MESSAGE

NAMESPACE       NAME    REVISION        SUSPENDED       READY   MESSAGE

NAMESPACE       NAME    REVISION        SUSPENDED       READY   MESSAGE

NAMESPACE       NAME    REVISION        SUSPENDED       READY   MESSAGE

NAMESPACE       NAME                    REVISION        SUSPENDED       READY   MESSAGE
monitoring      helmrelease/gatus       1.5.1           True            False   Helm rollback failed: release gatus failed: context deadline exceeded

                                                                                Last Helm logs:

                                                                                preparing rollback of gatus
                                                                                rolling back gatus (current: v2, target: v1)
                                                                                creating rolled back release for gatus
                                                                                performing rollback of gatus
```

#### Scenario B

or it will fail with the same error as before, i.e: "Helm upgrade failed: another operation (install/upgrade/rollback) is in progress".

If the HelmRelease is still in the failed state, it's likely related to the helm-controller restarting. To resolve the issue, do the following.

1. List secrets containing the affected HelmRelease name.

**Example**

```
sh.helm.release.v1.blackbox-exporter.v1         helm.sh/release.v1                    1      13d
sh.helm.release.v1.gatus.v1                     helm.sh/release.v1                    1      13d
sh.helm.release.v1.gatus.v2                     helm.sh/release.v1                    1      6d13h
sh.helm.release.v1.gatus.v3                     helm.sh/release.v1                    1      6d13h
sh.helm.release.v1.gatus.v4                     helm.sh/release.v1                    1      6m46s
sh.helm.release.v1.gatus.v5                     helm.sh/release.v1                    1      5m30s
```

2. Find and delete the most recent revision secret (i.e. `sh.helm.release.v1.*.<revision>`)

**Example**

```
kubectl get secrets -n monitoring | grep gatus | awk '{ print $1 }' | xargs -I{} sh -c "kubectl delete secret -n monitoring {}
```

3. suspend/resume the HelmRelease to trigger a reconciliation

**Example**

```
flux resume hr gatus -n monitoring
```

4. You should see the HelmRelease get reconciled then eventually the upgrade/install will succeed.

### Additional information

+ https://support.d2iq.com/hc/en-us/articles/8295311458964-Resolving-issues-with-HelmReleases-that-are-failed-
+ https://github.com/fluxcd/helm-controller/issues/149

### Manually rollback to a previous revision

1. List all the releases
2. Check the history for that release
3. Rollback the release to a previous revision

```
helm list -Aa
helm history <release> -n <name-space>
helm rollback <release> <revision> -n <name-space>
```
