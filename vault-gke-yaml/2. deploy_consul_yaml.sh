#Create consul service in namespace vault-deploy

kubectl create -f consulservice.yaml -n vault-deploy

#Install 3 Pods for Consul to run in
kubectl create -f consulstatefulset.yaml -n vault-deploy

#Command to delete pods
kubectl delete -f consulstatefulset.yaml
