

# Kind multinode cluster

L'idée est de pouvoir faire rapidement un cluster 3 noeuds 12 ou 24 Go de Ram pour les TPs.

- Avec un LoadBalancer fonctionnel
- Avec un ingress nginx
- Avec de limites de resources sur les noeuds (au moins pour le scheduling parce pas possible de hard limit vu le fonctionnement nested cgroups)
- Avec de tooling préinstallé ?
    - registry
    - prometheus
    - CI/CD ?

## Multimaster

Il faut supprimer la taint noSchedule

## Activer le Loadbalancer

source :
- https://github.com/kubernetes-sigs/cloud-provider-kind?tab=readme-ov-file#install
- https://kind.sigs.k8s.io/docs/user/loadbalancer/

Seulement dans la config 3 masters où on schedule des conteneurs sur les noeuds master il faut supprimer le label `node.kubernetes.io/exclude-from-external-load-balancers-node/kind-control-plane` sur les noeuds

Sinon le principe c'est simplement de lancer en parallèle de kind le programme go `cloud-provider-kind &`

# Troubleshooting

- Coredns : erreur pour trouver le service kubernetes => firewalld/ufw viens messup avec docker => arrêter le firewall