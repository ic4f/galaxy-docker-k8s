#! /usr/bin/env bash

kubectl delete service   galaxy-service
kubectl delete deploy    galaxy-web-deploy
kubectl delete deploy    galaxy-job-deploy
kubectl delete configmap galaxy-config
kubectl delete ingress   galaxy-ingress
kubectl delete pvc       galaxy-pvc
kubectl delete pv        galaxy-pv

kubectl delete service   postgres-service
kubectl delete deploy    postgres-deploy
kubectl delete configmap postgres-config
kubectl delete pvc       postgres-pvc
kubectl delete pv        postgres-pv
