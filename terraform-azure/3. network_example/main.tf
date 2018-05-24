
resource "azurerm_resource_group" "mytfirstrg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags {
    environment = "${var.resource_group_tag}"
  }
}
