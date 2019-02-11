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

resource "vault_auth_backend" "example" {
  type = "${var.test_vault_auth}"
  path = ${lookup(vault_auth_map, var.test_vault_auth)}"
}
