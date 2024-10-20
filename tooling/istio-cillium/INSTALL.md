
# Faire cohabiter Istio et Cilium

source: https://docs.cilium.io/en/latest/network/servicemesh/istio/


Cilium est un CNI généraliste qui fournit des fonctionnalités de service mesh (controle du trafic et chiffrement mTLS notamment).

Istio fonctionne en installant un CNI supplémentaire au cluster.

Faire cohabiter les deux n'est pas simple.

La méthode la plus simple est d'installer Istio en mode Ambiant (plutôt que sidecar) et de configurer Cilium avec quelques paramètres supplémentaires dans sa configMap.

