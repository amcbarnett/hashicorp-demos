variable "resource_group_name" {
  default = "myResourceGroup"
}

variable "resource_group_location" {
    type = "string"
    default = "East US"
    description = "This variable defines the…."
}
variable "resource_group_tag" { 
    type = "string" 
    default = "Production" 
    description = "Production resource tag"
}


/*variable "ARM_SUBSCRIPTION_ID" {
 
}

variable "ARM_CLIENT_ID" {
  
}
variable "ARM_CLIENT_SECRET" {

}
variable "ARM_TENANT_ID" {
 
}
*/

/*
{
    "cloudName": "AzureCloud",
    "id": "c0a607b2-6372-4ef3-abdb-dbe52a7b56ba",
    "isDefault": true,
    "name": "360k Sponsored",
    "state": "Enabled",
    "tenantId": "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec",
    "user": {
      "name": "ancil@hashicorp.com",
      "type": "user"
    }*/