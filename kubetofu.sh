#!/bin/bash

set -eu
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o pipefail

_print_help() {
  cat <<HEREDOC
./run.sh setup or ./run.sh all or ./run.sh full: setup infra with terraform and ansible

HEREDOC
}

###############################################################################
# Program Functions
###############################################################################

_ping_cluster(){
    # Read the file line by line
    while IFS= read -r line; do
        echo "pinging $line"
        ping -c3 $line
    done < "$IP_FILE_PATH"
    kubectl get nodes
}

_metallb_install(){
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
    export MANIFEST="metallb-config.yaml"
    cat <<EOF > $MANIFEST
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: production
  namespace: metallb-system
spec:
  addresses:
EOF
    while IFS= read -r line; do
        echo "        - $line/32" | tee -a $MANIFEST 
    done < "$IP_FILE_PATH"
    kubectl apply -f $MANIFEST
    rm $MANIFEST
}

_ingress_install(){
    kubectl apply -f tooling/ingress-nginx-kubetofu
}

_cluster_bootstrap() {
    _ingress_install
    _metallb_install
}


_main() {
    source ./env

    if [[ "${1:-}" =~ ^-h|--help$  ]]
    then
        _print_help
    elif [[ "${1:-}" =~ ^cluster_bootstrap[\ setup]?$  ]]
    then
        _cluster_bootstrap
    elif [[ "${1:-}" =~ ^ping_cluster[\ setup]?$  ]]
    then
        _ping_cluster
    fi
}

# Call `_main` after everything has been defined.
_main "$@"