#!/bin/sh

# install Helm 
curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
tar -C /tmp/ -zxvf /tmp/helm.tar.gz
mv /tmp/linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm

APP_VERSION="1.10.1"
CHART_VERSION="4.10.1"
sleep 1
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
sleep 1
helm search repo ingress-nginx --versions
helm template ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --version ${CHART_VERSION} --namespace ingress-nginx > /vagrant/confs/nginx-ingress.${APP_VERSION}.yaml

kubectl create namespace ingress-nginx
kubectl apply -f /vagrant/confs/nginx-ingress.${APP_VERSION}.yaml
kubectl apply -f /vagrant/confs/depl.yaml

