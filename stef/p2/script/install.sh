!/bin/bash


kubectl apply -f /vagrant/confs/traefik-deployement.yaml >/dev/null 2>&1
kubectl apply -f /vagrant/confs/depl.yaml >/dev/null 2>&1