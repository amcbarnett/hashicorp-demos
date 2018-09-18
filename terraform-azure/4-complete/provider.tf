/*provider "azurerm" {
  /*subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  
}*/

provider "azurerm" {
  subscription_id = "${data.vault_generic_secret.cyberark.data["subscription_id"]}"
  client_id       = "${data.vault_generic_secret.cyberark.data["client_id"]}"
  client_secret   = "${data.vault_generic_secret.cyberark.data.client_secret["value"]}"
  tenant_id       = "${data.vault_generic_secret.cyberark.data.tenant_id["value"]}"
}

provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  # address = "https://vault.example.net:8200"
  # set VAULT_TOKEN as a sensitive variable also to access Cybera=Ark secret engine
}

data "vault_generic_secret" cyberark {
  path = "secret/ancil/azure/credentials"
}