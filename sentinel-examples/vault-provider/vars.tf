variable "vault_auth_map" {
  type = "map"
  default = {
    aws = "ancil-aws"
    azure = "ancil-azure"
    k8s = "ancil-k8s"
    github = "ancil-github"
    approle = "ancil-approle"
  }
}

variable "test_vault_auth" {
  description = "Vault auth backend to test"
  default = "aws"
}
