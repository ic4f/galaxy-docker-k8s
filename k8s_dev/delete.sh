#! /usr/bin/env bash

kubectl delete -f postgres-config.yml
kubectl delete -f postgres.yml

kubectl delete -f galaxy-config.yml
kubectl delete -f galaxy.yml
