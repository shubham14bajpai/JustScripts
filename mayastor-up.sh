#!/bin/bash
set +ex

#echo 512 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

kubectl label node 127.0.0.1 openebs.io/engine=mayastor

kubectl create namespace mayastor

# apply the rbac
kubectl create -f https://raw.githubusercontent.com/openebs/Mayastor/master/deploy/moac-rbac.yaml

# apply the crds
kubectl apply -f https://raw.githubusercontent.com/openebs/Mayastor/master/csi/moac/crds/mayastorpool.yaml

# apply the dependencies
kubectl apply -f https://raw.githubusercontent.com/openebs/Mayastor/master/deploy/nats-deployment.yaml
sleep 30
kubectl -n mayastor get pods --selector=app=nats

# apply the csi plugin
kubectl apply -f https://raw.githubusercontent.com/openebs/Mayastor/master/deploy/csi-daemonset.yaml
sleep 30
kubectl -n mayastor get daemonset mayastor-csi

# apply control plane
kubectl apply -f https://raw.githubusercontent.com/openebs/Mayastor/master/deploy/moac-deployment.yaml
sleep 30
kubectl get pods -n mayastor --selector=app=moac

# apply data plane
kubectl apply -f https://raw.githubusercontent.com/openebs/Mayastor/master/deploy/mayastor-daemonset.yaml
sleep 30
kubectl -n mayastor get daemonset mayastor

sleep 60
# verify install 
kubectl get pods -n mayastor
kubectl get msn
