# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "mytfirstrg" {
  name     = "myfirstResourceGroup"
  location = "East US"

  tags {
    environment = "Development"
  }
}
