

#Initialize Vault

VAULT_POD=$(kubectl get pods --namespace vault-deploy -l "app=vault" -o jsonpath="{.items[0].metadata.name}")
VAULT_SERVICE=$(kubectl get svc -l app=vault -o jsonpath="{.items[0].metadata.name}")

## Using Command Line
#kubectl exec -it vault-0 -c vault -- /bin/sh

#kubectl exec -it ${VAULT_POD} -c ${VAULT_SERVICE} -- /bin/sh export VAULT_ADDR=http://127.0.0.1:8200

kubectl exec -it ${VAULT_POD} -c ${VAULT_SERVICE} -- /bin/sh -c 'VAULT_ADDR=http://localhost:8200 vault operator init -key-shares=1 -key-threshold=1'

#Unseal Key 1: xx

#Initial Root Token: xx

export VAULT_UNSEAL="xxx"
export VAULT_TOKEN="xxx"

for v in `kubectl get pods | grep vault | cut -f1 -d' '`; do kubectl exec -ti $v -c vault -- /bin/sh -c "VAULT_ADDR=http://localhost:8200 vault operator unseal ${VAULT_UNSEAL}
"; done

for v in `kubectl get pods | grep vault | cut -f1 -d' '`; do kubectl exec -ti $v -c vault -- /bin/sh -c 'VAULT_ADDR=http://localhost:8200 vault status'; done


#export VAULT_TOKEN=$(kubectl logs $VAULT_POD vault | grep 'Root Token' | cut -d' ' -f3)

#export VAULT_ADDR=http://127.0.0.1:8200

# run this on a second terminal
#kubectl port-forward $VAULT_POD 8200

#echo $VAULT_TOKEN | vault login -
#vault status


-------------------------------------------

#1. Create Kubernetes Service Account

# A service account can have multiple namespaces
# kubectl create serviceaccount vault-auth

#kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
#kubectl create clusterrolebinding role-tokenreview-binding --clusterrole=system:auth-delegator --serviceaccount=k8s-app1:vault-app

# 2. Grant service account ability to access the TokenReviewer API via RBAC


kubectl create serviceaccount k8s-app1
kubectl create serviceaccount k8s-app2

$ cat > vault-serviceaccount.yml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: vault-deploy
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: vault-deploy
- kind: ServiceAccount
  name: k8s-app1
  namespace: vault-deploy
- kind: ServiceAccount
  name: k8s-app2
  namespace: vault-deploy
EOF

kubectl apply -f vault-serviceaccount.yml


-----------------



# 3. Enable Kubernetes Auth Method
#export LB_IP="$(gcloud compute addresses describe vault --region us-east1 --format 'value(address)')"

export GOOGLE_CLOUD_PROJECT="mckingdom-gcp"
export GOOGLE_ZONE="us-east4-a"
export GOOGLE_CLUSTER="k8s-mcb"

export CLUSTER_NAME="gke_${GOOGLE_CLOUD_PROJECT}_${GOOGLE_ZONE}_${GOOGLE_CLUSTER}"

#Note: Command for all clusters: 
# kubectl config view -o jsonpath='{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'

/*
#export VAULT_SA_NAME="$(kubectl get serviceaccount vault-auth -o go-template='{{ (index .secrets 0).name }}')"
#export SA_JWT_TOKEN="$(kubectl get secret ${VAULT_SA_NAME} -o go-template='{{ .data.token }}' | base64 --decode)"
#export K8S_HOST="$(kubectl config view --raw \
#    -o go-template="{{ range .clusters }}{{ if eq .name \"${CLUSTER_NAME}\" }}{{ index .cluster \"server\" }}{{ end }}{{ end }}")"
#export K8S_CACERT="$(kubectl config view --raw \
#    -o go-template="{{ range .clusters }}{{ if eq .name \"${CLUSTER_NAME}\" }}{{ index .cluster \"certificate-authority-data\" }}{{ end }}{{ end }}" | base64 --decode)"

export VAULT_SA_NAME=$(kubectl get serviceaccount vault-auth -o jsonpath="{.secrets[*]['name']}")
export SA_JWT_TOKEN=$(kubectl get secret ${VAULT_SA_NAME} -o jsonpath="{.data.token}" | base64 --decode; echo)
export K8S_CACERT=$(kubectl get secret ${VAULT_SA_NAME} -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
#export K8S_HOST=$(kubectl exec -it vault-0 -c vault -- /bin/sh -c 'echo $KUBERNETES_SERVICE_HOST')
#echo $K8S_HOST | tr -d '\n'
#export K8S_HOST=$(kubectl exec -it vault-0 -c vault -- /bin/sh -c 'echo $KUBERNETES_SERVICE_HOST | tr -d \'\n\' ')
export K8S_HOST=$(kubectl exec -it vault-0 -c vault -- /bin/sh -c "echo \$KUBERNETES_SERVICE_HOST | tr -d '\n' ")

export VAULT_SERVICE=$(kubectl get svc -l app=vault -o jsonpath="{.items[0].metadata.name}")


echo ${VAULT_SA_NAME}
echo ${VAULT_SERVICE}
echo ${SA_JWT_TOKEN}
echo ${K8S_HOST}
echo ${K8S_CACERT}

---

kubectl exec -it vault-0 -c vault -- /bin/sh

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN="s.dj0373jLLXaxOndDVzui2yeI"

vault auth enable kubernetes

vault write auth/kubernetes/config \
    kubernetes_host="${K8S_HOST}" \
    kubernetes_ca_cert="${K8S_CACERT}" \
    token_reviewer_jwt="${SA_JWT_TOKEN}"

vault write auth/kubernetes/config \
  token_reviewer_jwt="${SA_JWT_TOKEN}" \
  kubernetes_host="https://10.55.240.1:443" \
  kubernetes_ca_cert="${K8S_CACERT}"


-----------------

#Create service accounts for two apps/ processes in a new name space vault-app


kubectl get serviceAccounts
kubectl get ns

vault write auth/kubernetes/role/testauth \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=vault-deploy \
    policies="admin-policy,default" \
    ttl=24h


vault write auth/kubernetes/role/app1 \
    bound_service_account_names=k8s-app1 \
    bound_service_account_namespaces=vault-deploy \
    policies="apps-policy, cert-policy" \
    ttl=24h


vault write auth/kubernetes/role/app2 \
    bound_service_account_names=k8s-app2 \
    bound_service_account_namespaces=vault-deploy \
    policies="apps-policy" \
    ttl=24h




---------------------

#To test K8s Auth with service account vault-auth
#Create a Temporary Image:

kubectl run --generator=run-pod/v1 tmp  -i --tty --serviceaccount=vault-auth --image alpine

kubectl attach tmp -c tmp -i -t

# some preq
$ apk update
$ apk add curl postgresql-client jq
# fetch the vault token of this specific pod

export KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
echo ${KUBE_TOKEN}

export VAULT_K8S_LOGIN=$(curl --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "testauth"}' http://vault:8200/v1/auth/kubernetes/login)

echo $VAULT_K8S_LOGIN | jq

X_VAULT_TOKEN=$(echo $VAULT_K8S_LOGIN | jq -r '.auth.client_token')

curl --header "X-Vault-Token: ${X_VAULT_TOKEN}" \
       --request GET \
       http://vault:8200/v1/secret/mysecret | jq

---------------------

---------------------

#To test K8s Auth with service account k8s-app1
#Create a Temporary Image:

kubectl run --generator=run-pod/v1 tmp-app1  -i --tty --serviceaccount=k8s-app1 --image alpine


kubectl attach tmp-app1 -c tmp-app1 -i -t

# some preq
$ apk update
$ apk add curl postgresql-client jq
# fetch the vault token of this specific pod

export KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
echo ${KUBE_TOKEN}

export VAULT_K8S_LOGIN=$(curl --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "app1"}' http://vault:8200/v1/auth/kubernetes/login)

echo $VAULT_K8S_LOGIN | jq

X_VAULT_TOKEN=$(echo $VAULT_K8S_LOGIN | jq -r '.auth.client_token')

curl --header "X-Vault-Token: ${X_VAULT_TOKEN}" \
       --request GET \
       http://vault:8200/v1/secret/mysecret | jq
       
curl --header "X-Vault-Token: ${X_VAULT_TOKEN}" \
       --request GET \
       http://vault:8200/v1/secret/topsecret | jq

------------------------

#To test K8s Auth with service account k8s-app2
#Create a Temporary Image:

kubectl run --generator=run-pod/v1 tmp-app2  -i --tty --serviceaccount=k8s-app2 --image alpine

kubectl attach tmp-app2 -c tmp-app2 -i -t

# some preq
$ apk update
$ apk add curl postgresql-client jq
# fetch the vault token of this specific pod

export KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
echo ${KUBE_TOKEN}

export VAULT_K8S_LOGIN=$(curl --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "app2"}' http://vault:8200/v1/auth/kubernetes/login)

echo $VAULT_K8S_LOGIN | jq

X_VAULT_TOKEN=$(echo $VAULT_K8S_LOGIN | jq -r '.auth.client_token')


curl --header "X-Vault-Token: ${X_VAULT_TOKEN}" \
       --request GET \
       http://vault:8200/v1/secret/mysecret | jq
       
curl --header "X-Vault-Token: ${X_VAULT_TOKEN}" \
       --request GET \
       http://vault:8200/v1/secret/topsecret | jq


