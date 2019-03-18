oc create ns vault-deploy --config=/etc.origin/mater/admin.kubecofig
oc get project


#Switch Context
oc config use-context vault-deploy 

# List Contexts
oc config current-context

#To Delete Context
#oc config delete-context vault-deploy
