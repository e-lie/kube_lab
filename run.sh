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


_kind_stop() {
    local prefix="$1"
    echo "Stop existing cluster $prefix..."
    docker ps --filter "name=^${prefix}" --format "{{.ID}}" | xargs -r docker stop >/dev/null 2>&1 
    docker ps --filter "name=^kindccm" --format "{{.ID}}" | xargs -r docker rm --force >/dev/null 2>&1 # rm envoy cloud-provider-kind containers
    docker ps --filter "name=^${prefix}" --format "{{.ID}}" | xargs -r docker update --restart=no >/dev/null 2>&1
    pkill cloud-provider
}

_kind_start() {
    local prefix="$1"
    echo "Start existing cluster $prefix..."
    docker ps -a --filter "name=^${prefix}" --format "{{.ID}}" | xargs -r docker start >/dev/null 2>&1
    # docker ps -a --filter "name=^kindccm" --format "{{.ID}}" | xargs -r docker start >/dev/null 2>&1
    docker ps -a --filter "name=^${prefix}" --format "{{.ID}}" | xargs -r docker update --restart=no >/dev/null 2>&1

    cloud-provider-kind >/dev/null 2>&1 &
}

_kind_create() {
    echo "Creat cluster $KIND_CLUSTER_NAME..."
    kind create cluster --config $KIND_CLUSTER_CONFIG_PATH
    cloud-provider-kind >/dev/null 2>&1 &
}

_cluster_up() {

    if [ ! -z $(docker ps -a --filter "name=^$KIND_CLUSTER_NAME" --format "{{.ID}}" | head -n 1) ]
    then
        _kind_start $KIND_CLUSTER_NAME
    else
        _kind_create 
    fi
    
}

_cluster_down() {
    _kind_stop $KIND_CLUSTER_NAME
}

_cluster_destroy() {
    _cluster_down
    kind delete cluster --name $KIND_CLUSTER_NAME
}

_argocd_login() {
    export ARGOCD_ADMIN_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode)
    export ARGOCD_SERVER_IP=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    printf "\\n############ argocd \\n ip : %s \\n login : admin \\n password : %s \\n\\n"  $ARGOCD_SERVER_IP $ARGOCD_ADMIN_PWD 
}

_argocd_install() {
    echo "############# Install ArgoCD"
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f - # create ns if not exist
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    kubectl apply -f $PWD/tooling-manifests/argocd/tooling-argocd-project.yaml
    _argocd_login
}

_ingress_install(){
    INGRESS_MANIFESTS_URL=https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    wget $INGRESS_MANIFESTS_URL -O $PWD/tooling-manifests/applied/ingress-nginx.yaml
}

_cluster_bootstrap() {
    _argocd_install
}

_main() {
    source ./env

    if [[ "${1:-}" =~ ^-h|--help$  ]]
    then
        _print_help
    elif [[ "${1:-}" =~ ^cluster_up[\ setup]?$  ]]
    then
        _cluster_up
    elif [[ "${1:-}" =~ ^cluster_down[\ setup]?$  ]]
    then
        _cluster_down
    elif [[ "${1:-}" =~ ^cluster_destroy[\ setup]?$  ]]
    then
        _cluster_destroy
    elif [[ "${1:-}" =~ ^cluster_bootstrap[\ setup]?$  ]]
    then
        _cluster_bootstrap
    elif [[ "${1:-}" =~ ^argocd_login[\ setup]?$  ]]
    then
        _argocd_login
    fi
}

# Call `_main` after everything has been defined.
_main "$@"