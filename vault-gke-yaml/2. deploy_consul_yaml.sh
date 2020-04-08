#Create consul service in namespace vault-deploy
#Review consulservice.yaml first

kubectl create -f consulservice.yaml -n vault-deploy

#Install 3 Pods for Consul to run in
#Review onsulstatefulset.yaml first
kubectl create -f consulstatefulset.yaml -n vault-deploy

#Command to delete pods
#kubectl delete -f consulstatefulset.yaml

kubectl get service

#Keep executing until three pods created and running
kubectl get pods

#Test that Consul is working
#In another Terminal on local mac forward port
kubectl port-forward consul-1 8500:8500

#Go to web for Console UI

#Go back to previous terminal or in a new terminal and run
kubectl exec -it consul-0 -c consul -- /bin/sh
> consul members
> exit
