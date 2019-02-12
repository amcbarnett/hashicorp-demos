cat <<EOF > vault.hcl
storage "consul" {
 address = "127.0.0.1:8500"
 path = "vault/"
 }
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "true"
}
disable_mlock="true"
disable_cache="true"
ui = "true"

max_least_ttl="10h"
default_least_ttl="10h"
raw_storage_endpoint=true
cluster_name="mycompany-vault"
EOF


# Create Vault Config Map

kubectl create ns vault-deploy

kubectl create configmap vault --from-file=vault.hcl -n vault-deploy
