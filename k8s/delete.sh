kubectl delete service gpsql
kubectl delete configmap postgres-config
kubectl delete pvc postgres-pv-claim
kubectl delete pv postgres-pv-volume
kubectl delete postgres

kubectl delete ingress galaxy-ingress
kubectl delete service galaxy
kubectl delete configmap galaxy-job-conf
kubectl delete pvc galaxy-pvc-claim
kubectl delete pv galaxy-pv-volume
kubectl delete deploy galaxy-web
kubectl delete deploy galaxy-job
