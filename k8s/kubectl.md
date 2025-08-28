# Manage Kubernetes using kubectl

## Installation
> ---this requires update---

```bash
# Set alias
alias k=kubectl
```

## Taints

```bash
# Taint node (do not schedule new pods)
kubectl taint nodes node1 key1=value1:NoSchedule # any key name

# Taint node (force eviction and do not schedule new pods)
kubectl taint nodes node1 ps=value1:NoExecute

# Remove node taint:
kubectl taint nodes node1 key1=value1:NoSchedule- # same key name as when tainted
kubectl taint nodes node1 ps=value1:NoExecute-
```

## Miscellaneous

```bash
# Get all custom resources that belong to Istio
kubectl api-resources | grep -i istio
```
