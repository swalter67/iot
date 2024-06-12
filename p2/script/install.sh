#!/bin/sh

export DEBIAN_FRONTEND=noninteractive
APP_VERSION="1.10.1"
CHART_VERSION="4.10.1"

# install Helm 
#curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
#chmod 700 get_helm.sh
#./get_helm.sh
# or install via apt
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get -y install apt-transport-https
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get -y install helm

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
helm repo update
#helm search repo ingress-nginx --versions
helm template ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --version ${CHART_VERSION} --namespace ingress-nginx > /vagrant/confs/nginx-ingress.${APP_VERSION}.yaml

kubectl create namespace ingress-nginx
kubectl apply -f /vagrant/confs/nginx-ingress.${APP_VERSION}.yaml
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
kubectl apply -f /vagrant/confs/depl.yaml


