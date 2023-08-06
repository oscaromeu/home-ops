

# How do I troubleshoot namespaces in a terminated state?

## Short description

To delete a namespace, Kubernetes must first delete all the resources in the namespace. Then,
it must check registered API services for the status. A namespace gets stuck in __Terminating__ stats for the following reasons:

+ The namespace contains resources that Kubernetes can't delete
+ An API service has a __False__ status

## Resolution

1. Save JSON file like in the following example:

```
kubectl get namespace TERMINATING_NAMESPACE -o json > tempfile.json
```

__Note:__ Replace __TERMINATING_NAMESPACE__ with the name of your stuck namespace.

2. Remove the finalizers array block from the __spec__ section of the JSON file:

```
"spec": {
        "finalizers": [
            "kubernetes"
        ]
    }
```

After you remove the finalizers array block, the __spec__ section of the JSON file looks like this:

```
"spec" : {
    }
```

3. To apply the changes, run the following command:

```
kubectl replace --raw "/api/v1/namespaces/TERMINATING_NAMESPACE/finalize" -f ./tempfile.json
```

__Note:__ Replace __TERMINATING_NAMESPACE__ with the name of your stuck namespace.

4. Verify that the terminating namespace is removed:

```
kubectl get namespaces
```
