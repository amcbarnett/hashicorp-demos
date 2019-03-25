# Create volumes to mount pv claims to (see hostpath example file)
oc create -f hostpathex.yaml

oc create -f vaultstatefulset.yaml -n vault-deploy

# Repeat intil you see three Vault nodes
oc get pods

#Run in a seperate terminal window
#Check vault UI
oc port-forward vault-0 8200:8200
