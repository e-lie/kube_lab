
# Lab Kubernetes pour les TPs avancés

## Kind

Créer un cluster local en utilisant kind et les resources dans le dossier `kind`

## Kubetofu

Kubetofu est le nom d'un fork personnel du projet hobby-kube pour fournir un lab kubernetes provisionnable pour chaque stagiaire d'une formation.

Il forme une nouvelle base pour les TPs avancés et les modules à la carte.

Pour provisionner le cluster de base on utilise un projet terraform à part (kube_tofu souvent le dossier d'à côté) qu'il faut ensuite renseigner dans le fichier env pour faire le lien avec les scripts de provisionning de ce projet