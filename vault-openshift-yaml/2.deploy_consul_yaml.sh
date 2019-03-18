#Create consul service in namespace vault-deploy
#Review consulservice.yaml first

oc create -f consulservice.yaml -n vault-deploy

# Create volumes to mount pv claims to (see hostpath example file)
oc create -f hostpathex.yaml

# Created privilegeduser service account:
oc create serviceaccount -n vault-deploy privilegeduser

#Added privileged scc to service account:
 oc adm policy add-scc-to-user privileged -n vault-deploy -z privilegeduser

#Install 3 Pods for Consul to run in
#Review onsulstatefulset.yaml first
oc create -f consulstatefulset.yaml -n vault-deploy

#Command to delete pods
#oc delete -f consulstatefulset.yaml

oc get service

#Keep executing until three pods created and running
oc get pods

#Test that Consul is working
#In another Terminal on local mac forward port
oc port-forward consul-1 8500:8500

#Go to web for Console UI

#Go back to previous terminal and run
consul members
