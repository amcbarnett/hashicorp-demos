#Create consul service in namespace vault-deploy

kubectl create -f consulservice.yaml -n vault-deploy

#Install 3 Pods for Consul to run in
kubectl create -f consulstatefulset.yaml -n vault-deploy

#Command to delete pods
#kubectl delete -f consulstatefulset.yaml

kubectl get service
kubectl get pods

#Test that Consul is working
#In another Terminal on local mac forward port
kubectl port-forward consul-1 8500:8500

#Go back to previous terminal and run
consul members
