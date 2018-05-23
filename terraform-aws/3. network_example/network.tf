resource "azurerm_virtual_network" "myfirstvn" {
	name = "${var.vn_name}"
	address_space = "${var.vn_address_space}"
	location = "${var.vn_location}"
	resource_group_name = "${var.resource_group_name}"
}