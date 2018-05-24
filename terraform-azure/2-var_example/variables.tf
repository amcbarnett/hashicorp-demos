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

