## MetalLB Install

https://metallb.io/installation/

### Avec `kubectl`

`kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml`

### Configuration de IP (a completer)

Sur cluster on premise : récupérez les ip publiques des noeuds du cluster par exemple

- `ping kube-prenom1.prenom.dopl.uk`
- `ping kube-prenom2.prenom.dopl.uk`
- etc...

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.10.0/32
  - 192.168.10.1/32
```