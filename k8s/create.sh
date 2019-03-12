kubectl create -f postgres-service.yml
kubectl create -f postgres-configmap.yml
kubectl create -f postgres-pv.yml
kubectl create -f postgres-deployment.yml

kubectl create -f galaxy-ingress.yml
kubectl create -f galaxy-service.yml
kubectl create -f galaxy-configmap.yml
kubectl create -f galaxy-pv.yml
kubectl create -f galaxy-web-deployment.yml
kubectl create -f galaxy-job-deployment.yml
