

kubectl create -f vaultstatefulset.yaml -n vault-deploy

# Repeat intil you see three Vault nodes
kubectl get pods

#Run in a seperate terminal window
#Check vault UI
kubectl port-forward vault-0 8200:8200
