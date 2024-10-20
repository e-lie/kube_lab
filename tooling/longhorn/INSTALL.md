

### Prérequis

Longhorn a besoin de tourner sur des hotes vm ou conteneurs avec iSCSI installé

### Install kubectl

`kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.1/deploy/longhorn.yaml`

### Création d'une storageClass

`kubectl create -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.1/examples/storageclass.yaml`

### Exposer l'interface d'admin de Longhorn avec un ingress

Prérequis : avoir un ingress NGINX qui fonctionne (et donc un metalLB on premise)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: longhorn-ingress
  namespace: longhorn-system
  annotations:
spec:
  ingressClassName: nginx

  rules:
  - host: "<domain-a-remplacer>"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: longhorn-frontend
            port:
              number: 80
```

Pour le domaine :

- dans le cas de kind avec ingress utilisez par exemple `longhorn.local.io` et l'ajouter a etc/hosts : `echo "127.0.0.1 longhorn.local.io" | sudo tee -a /etc/hosts`

- dans le cas du kube_tofu lab : utiliser `longhorn.<prenom>.dopl.uk`

## Activer les snapshots de persistent volumes via la fonctionnalité CSI

Les plugins CSI peuvent exposer une fonctionnalité de snapshot de leurs volumes.

Longhorn supporte cette fonctionnalité mais il faut installer des CRDs et un composant nommé `external-snapshotter` **dans une version spécifique:

- Voir la doc de longhorn de la bonne version (ici 1.7.1): https://longhorn.io/docs/1.7.1/snapshots-and-backups/csi-snapshot-support/enable-csi-snapshot-support/

Pour longhorn 1.7.1 il faut installer les crds et snapshotter version 7.0.2:

- `git clone -b v7.0.2 https://github.com/kubernetes-csi/external-snapshotter.git /tmp/external-snapshotter`
- `kubectl create -k /tmp/external-snapshotter/client/config/crd`
- `kubectl create -k /tmp/external-snapshotter/deploy/kubernetes/snapshot-controller`

```sh
kubectl apply -f - <<EOF
kind: VolumeSnapshotClass
apiVersion: snapshot.storage.k8s.io/v1
metadata:
  name: longhorn
driver: driver.longhorn.io
deletionPolicy: Delete
EOF
```