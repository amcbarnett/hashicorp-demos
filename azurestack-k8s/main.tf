resource "azurerm_resource_group" "myterraformgroup" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags {
    environment = "${var.resource_group_tag}"
  }
}