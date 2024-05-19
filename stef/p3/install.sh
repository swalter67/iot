#!/bin/bash

# Chemin du répertoire de configuration
CONFIG_DIR="/home/walter/Desktop/iot2/iot/stef/p3/confs"

# Vérification des privilèges root
if [ "$(id -u)" != "0" ]; then
    echo "Ce script doit être exécuté avec les droits superutilisateur."
    exit 1
fi

# Mise à jour des paquets existants
apt-get update && apt-get upgrade -y

# Installation des dépendances nécessaires
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Installation de Docker
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé. Installation de Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
    echo "Docker installé avec succès."
else
    echo "Docker est déjà installé."
fi

# Installation de kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/.

# Installation de k3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Création d'un cluster k3d
k3d cluster create mycluster --port 8080:80@loadbalancer --port 8888:8888@loadbalancer --k3s-arg "--disable=traefik@server:0" --verbose

# Vérification que kubectl et k3d sont installés
command -v kubectl >/dev/null 2>&1 || { echo "kubectl n'a pas été installé correctement." ; exit 1; }
command -v k3d >/dev/null 2>&1 || { echo "k3d n'a pas été installé correctement." ; exit 1; }

# Configuration du contexte kubectl
mkdir -p /home/walter/.kube
k3d kubeconfig get mycluster > /home/walter/.kube/config
kubectl config use-context k3d-mycluster || { echo "Le contexte k3d-mycluster n'a pas été trouvé." ; exit 1; }

# Installation de ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f $CONFIG_DIR/argocd.yaml

# Déploiement de l'application dans le namespace 'dev'
kubectl create namespace dev
kubectl apply -f $CONFIG_DIR/will_app.yaml -n dev
kubectl apply -f $CONFIG_DIR/ingress.yaml -n dev

echo "Installation terminée. ArgoCD et k3d sont prêts à l'emploi, normalement !"
