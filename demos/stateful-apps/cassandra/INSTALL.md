
# Installer un Cassandra via le chart de Bitnami

Nous pouvons utiliser ArgoCD pour installer le chart car cet operateur d'applications GitOps permet de plus facilement visualiser et analyser le résultat de l'installation (avant même d'appliquer le chart dans le cluster)

Allons voir le chart sur https://artifacthub.io: https://artifacthub.io/packages/helm/bitnami/cassandra

Voir les paramètres possibles d'installation: https://artifacthub.io/packages/helm/bitnami/cassandra?modal=values

Créons un fichier `cassandra-values.yaml` et utilisons les valeurs suivantes:

```yaml

```

- Appliquez le manifest `mysql-argocd-chart-ns.yaml` puis allons observer dans argoCD

- Templatez les manifests puis étudions le code de l'application: `helm template cassandra-chart bitnami/cassandra --version=12.0.3 --values=cassandra-values.yaml > cassandra-chart-manifests.yaml`




