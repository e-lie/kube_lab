# Cloud Native PostgreSQL

## Installation kubectl

```sh
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.23/releases/cnpg-1.23.5.yaml
```

(https://cloudnative-pg.io/documentation/1.23/installation_upgrade/#installation-on-kubernetes)

## Déployer un cluster PostgreSQL

Basic cluster en bootstrappant une nouvelle base de donnée vide et un utilisateur:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-example-initdb
spec:
  instances: 3

  bootstrap:
    initdb:
      database: app
      owner: app
      secret:
        name: app-secret

  storage:
    size: 1Gi
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: kubernetes.io/basic-auth
data:
  username: app
  password: cGFzc3dvcmQ=
```

L'exemple de bootstrap ci-dessus va :

- créer un nouveau dossier PGDATA en utilisant la commande native initdb de PostgreSQL
- créer un utilisateur non privilégié nommé **app**
- définir le mot de passe de ce dernier (**app**) en utilisant celui contenu dans le secret **app-secret** (assurez-vous que le nom d'utilisateur correspond bien au nom du propriétaire)
- créer une base de données appelée **app**, appartenant à l'utilisateur **app**.

https://cloudnative-pg.io/documentation/1.23/bootstrap/


## Déployer un cluster dans une version spécifique de Postgres

Pour cela il faut créer un


```yaml
apiVersion: postgresql.cnpg.io/v1
kind: ImageCatalog
metadata:
  name: postgresql
  namespace: default
spec:
  images:
    - major: 15
      image: ghcr.io/cloudnative-pg/postgresql:15.6
    - major: 16
      image: ghcr.io/cloudnative-pg/postgresql:17.0
```

Puis l'utiliser

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-example
spec:
  instances: 3
  imageCatalogRef:
    apiGroup: postgresql.cnpg.io
    kind: ImageCatalog
    name: postgresql
    major: 16
  storage:
    size: 1Gi
```

Les "image catalogs" servent notamment de base pour laisser Cloudnative-PG faire un upgrade automatique des versions mineures de Postgres.

## Examples plus avancés

Cloud Native PG fournit des fonctionnalités confortable pour activer la plupart des fonctionnalités majeures de Postgres via les manifestes de CRDs:

https://cloudnative-pg.io/documentation/1.23/samples/